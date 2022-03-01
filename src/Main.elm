module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, src, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import RepoStats exposing (mostUsedLanguage, totalForks, totalStars)


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


init : String -> ( Model, Cmd Msg )
init pw =
    ( { initialModel | githubPass = pw }, Cmd.none )



-- MODEL


type alias Model =
    { githubPass : String
    , searchText : String
    , error : Maybe Http.Error
    , loading : Bool
    , profile : Maybe Profile
    , repos : Maybe (List Repo)
    , activity : Maybe Activity
    }


type alias Profile =
    { username : String
    , avatarUrl : String
    , url : String
    , name : String
    , company : String
    , blog : String
    , location : String
    , email : String
    , bio : String
    , twitterUsername : String
    , repos : Int
    , gists : Int
    , followers : Int
    , following : Int
    , createdAt : String
    }


type alias Repo =
    { name : String
    , description : String
    , language : String
    , starCount : Int
    , forksCount : Int
    , openIssuesCount : Int
    }

type alias Activity =
    { activityType : String
    , createdAt : String
    }


initialModel : Model
initialModel =
    { githubPass = ""
    , searchText = ""
    , error = Nothing
    , loading = False

    -- , profile = Just { avatarUrl = "https://avatars.githubusercontent.com/u/2918581?v=4" , bio = "Source code and more for the most popular front-end framework in the world." , blog = "https://getbootstrap.com" , company = "" , createdAt = "2012-11-29T05:47:03Z" , email = "" , followers = 0 , following = 0 , gists = 0 , location = "San Francisco" , name = "Bootstrap" , repos = 24 , twitterUsername = "getbootstrap" , url = "https://api.github.com/users/twbs" , username = "twbs" }
    , profile = Nothing
    , repos = Just []
    , activity = Nothing
    }



-- UPDATE


type Msg
    = UpdateSearchBox String
    | Search
    | LoadProfile (Result Http.Error Profile)
    | LoadRepos (Result Http.Error (List Repo))
    | LoadActivity (Result Http.Error Activity)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchBox input ->
            ( { model | searchText = input }
            , Cmd.none
            )

        Search ->
            ( { model | searchText = "", profile = Nothing, repos = Nothing, error = Nothing, loading = True }
            , Cmd.batch
                [ fetchProfile model.searchText model.githubPass
                , fetchRepos model.searchText model.githubPass
                , fetchActivity model.searchText model.githubPass
                ]
            )

        LoadProfile (Ok profile) ->
            ( { model | profile = Just profile }
            , Cmd.none
            )

        LoadProfile (Err error) ->
            ( { model | error = Just error, loading = False }
            , Cmd.none
            )

        LoadRepos (Ok repos) ->
            ( { model | repos = Just repos, loading = False }
            , Cmd.none
            )

        LoadRepos (Err error) ->
            ( { model | error = Just error, loading = False }
            , Cmd.none
            )

        LoadActivity (Ok activity) ->
            ( { model | activity = Just activity }
            , Cmd.none
            )

        LoadActivity (Err error) ->
            ( { model | error = Just error, loading = False }
            , Cmd.none
            )


fetchProfile : String -> String -> Cmd Msg
fetchProfile usernameSearch githubPass =
    Http.request
        { method = "GET"
        , headers = [ authorisationHeader githubPass ]
        , url = "https://api.github.com/users/" ++ usernameSearch
        , body = Http.emptyBody
        , expect = Http.expectJson LoadProfile profileDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


fetchRepos : String -> String -> Cmd Msg
fetchRepos usernameSearch githubPass =
    Http.request
        { method = "GET"
        , headers = [ authorisationHeader githubPass ]
        , url = "https://api.github.com/users/" ++ usernameSearch ++ "/repos?per_page=100"
        , body = Http.emptyBody
        , expect = Http.expectJson LoadRepos (list repoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }
fetchActivity : String -> String -> Cmd Msg
fetchActivity usernameSearch githubPass =
    Http.request
        { method = "GET"
        , headers = [ authorisationHeader githubPass ]
        , url = "https://api.github.com/users/" ++ usernameSearch ++ "/events?per_page=1"
        , body = Http.emptyBody
        , expect = Http.expectJson LoadActivity (Json.Decode.index 0 activityDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


authorisationHeader : String -> Http.Header
authorisationHeader password =
    Http.header "Authorization" ("Basic " ++ password)


profileDecoder : Decoder Profile
profileDecoder =
    succeed Profile
        |> required "login" string
        |> required "avatar_url" string
        |> required "url" string
        |> optional "name" string ""
        |> optional "company" string ""
        |> optional "blog" string ""
        |> optional "location" string ""
        |> optional "email" string ""
        |> optional "bio" string ""
        |> optional "twitter_username" string ""
        |> required "public_repos" int
        |> required "public_gists" int
        |> required "followers" int
        |> required "following" int
        |> required "created_at" string


repoDecoder : Decoder Repo
repoDecoder =
    succeed Repo
        |> required "name" string
        |> optional "description" string ""
        |> optional "language" string ""
        |> required "stargazers_count" int
        |> required "forks" int
        |> required "open_issues_count" int

activityDecoder : Decoder Activity
activityDecoder =
    succeed Activity
        |> required "type" string
        |> required "created_at" string


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Http.Timeout ->
            "Unable to reach the server, timed out"

        Http.NetworkError ->
            "Unable to reach the server, check your network connection"

        Http.BadStatus 500 ->
            "The server had a problem, try again later"

        Http.BadStatus 404 ->
            "Unable to find GitHub profile"

        Http.BadStatus _ ->
            "Unknown error"

        Http.BadBody errorMessage ->
            errorMessage



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ div [ class "header" ]
            [ h1 [] [ text "Git Stats" ]
            , form [ onSubmit Search ]
                [ input
                    [ onInput UpdateSearchBox
                    , value model.searchText
                    , placeholder "Enter GitHub Username:"
                    ]
                    []
                ]
            ]
        , viewMainContent model
        ]


viewMainContent : Model -> Html Msg
viewMainContent model =
    if model.loading then
        div [ class "loading-spinner" ] []

    else
        case model.error of
            Just error ->
                div [ class "error-toast" ]
                    [ span [] [ text "An error occurred: " ]
                    , span [] [ text (errorToString error) ]
                    ]

            Nothing ->
                viewProfile model.profile model.repos model.activity


viewProfile : Maybe Profile -> Maybe (List Repo) -> Maybe Activity -> Html Msg
viewProfile maybeProfile maybeRepos maybeActivity =
    case ( maybeProfile, maybeRepos, maybeActivity ) of
        ( Just profile, Just repos, Just activity ) ->
            div [ class "profile" ]
                [ viewProfileSummary profile
                , viewProfileCards profile repos activity
                ]

        ( _, _, _ ) ->
            div [] []


viewProfileSummary : Profile -> Html Msg
viewProfileSummary profile =
    div
        [ class "profile-summary" ]
        [ div
            [ class "profile-avatar" ]
            [ img [ src profile.avatarUrl ] [] ]
        , div
            [ class "profile-details" ]
            [ div [ class "profile-name" ] [ text profile.username ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-user" ] [] ]
                , span [] [ text profile.name ]
                ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-location-dot" ] [] ]
                , span [] [ text profile.location ]
                ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-suitcase" ] [] ]
                , span [] [ text profile.company ]
                ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-link" ] [] ]
                , span [] [ text profile.blog ]
                ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-at" ] [] ]
                , span [] [ text profile.email ]
                ]
            , div [ class "profile-meta-data" ]
                [ div [] [ i [ class "fa fa-brands fa-twitter" ] [] ]
                , span [] [ text profile.twitterUsername ]
                ]
            ]
        ]


viewProfileCards : Profile -> List Repo -> Activity -> Html Msg
viewProfileCards profile repos activity =
    div [ class "card-container" ]
        [ viewReposCard profile repos
        , viewFollowersCard profile repos
        , viewCreatedCard profile activity
        ]


viewReposCard : Profile -> List Repo -> Html Msg
viewReposCard profile repos =
    let
        mostUsedLanguageTuple =
            RepoStats.mostUsedLanguage repos

        mostUsedLanguage =
            Tuple.first mostUsedLanguageTuple

        mostUsedLanguageCount =
            Tuple.second mostUsedLanguageTuple
    in
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ div [ class "card-front" ]
                [ span [ class "fa fa-code card-icon" ] []
                , div [ class "card-label" ] [ text "Number of repos" ]
                , div [ class "card-stat" ] [ text (String.fromInt profile.repos) ]
                , div [ class "card-label" ] [ text "Number of gists" ]
                , div [ class "card-stat" ] [ text (String.fromInt profile.gists) ]
                ]
            , div [ class "card-back" ]
                [ span [ class "fa fa-language card-icon" ] []
                , div [ class "card-label" ] [ text "Most used language" ]
                , div [ class "card-stat" ] [ text mostUsedLanguage ]
                , div [ class "card-label" ] [ text ("Number of " ++ mostUsedLanguage ++ " repos") ]
                , div [ class "card-stat" ] [ text (String.fromInt mostUsedLanguageCount) ]
                ]
            ]
        ]


viewFollowersCard : Profile -> List Repo -> Html Msg
viewFollowersCard profile repos =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ div [ class "card-front" ]
                [ span [ class "fa fa-user-group card-icon" ] []
                , div [ class "card-label" ] [ text "Followers" ]
                , div [ class "card-stat" ] [ text (String.fromInt profile.followers) ]
                , div [ class "card-label" ] [ text "Following" ]
                , div [ class "card-stat" ] [ text (String.fromInt profile.following) ]
                ]
            , div [ class "card-back" ]
                [ span [ class "fa fa-star card-icon" ] []
                , div [ class "card-label" ] [ text "Repo Stars" ]
                , div [ class "card-stat" ] [ text (RepoStats.totalStars repos) ]
                , div [ class "card-label" ] [ text "Repo Forks" ]
                , div [ class "card-stat" ] [ text (RepoStats.totalForks repos) ]
                ]
            ]
        ]


viewCreatedCard : Profile -> Activity -> Html Msg
viewCreatedCard profile activity =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ div [ class "card-front" ]
                [ span [ class "fa fa-clock card-icon" ] []
                , div [ class "card-label" ] [ text "Account active since" ]
                , div [ class "card-stat date-text" ] [ text (String.left 10 profile.createdAt) ]
                , div [ class "card-stat time-text" ] [ text (String.slice 11 16 profile.createdAt) ]
                ]
            , div [ class "card-back" ]
                [ span [ class "fa fa-clock card-icon" ] []
                , div [ class "card-label" ] [ text "Last activity" ]
                , div [ class "card-stat date-text" ] [ text (String.left 10 activity.createdAt) ]
                , div [ class "card-stat time-text" ] [ text (String.slice 11 16 activity.createdAt) ]
                , div [ class "card-label" ] [ text "Activity type" ]
                , div [ class "card-stat date-text" ] [ text (String.left 10 activity.activityType) ]
                ]
            ]
        ]
