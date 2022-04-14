module Main exposing (..)

import Browser
import Browser.Dom as Dom exposing (focus)
import Html exposing (..)
import Html.Attributes exposing (autocomplete, class, id, placeholder, src, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, int, list, maybe, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import RepoStats exposing (mostUsedLanguage, totalForks, totalStars)
import Task exposing (attempt)


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
init environment =
    ( { initialModel | environment = environment }, Cmd.none )



-- MODEL


type alias Model =
    { environment : String
    , searchText : String
    , error : Maybe Http.Error
    , loading : Bool
    , profile : Maybe Profile
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
    , repo_count : Int
    , gists : Int
    , followers : Int
    , following : Int
    , createdAt : String
    , repos : Maybe (List Repo)
    , activity : Maybe Activity
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
    { environment = ""
    , searchText = ""
    , error = Nothing
    , loading = False

    -- , profile = Just { avatarUrl = "https://avatars.githubusercontent.com/u/2918581?v=4" , bio = "Source code and more for the most popular front-end framework in the world." , blog = "https://getbootstrap.com" , company = "" , createdAt = "2012-11-29T05:47:03Z" , email = "" , followers = 0 , following = 0 , gists = 0 , location = "San Francisco" , name = "Bootstrap" , repos = 24 , twitterUsername = "getbootstrap" , url = "https://api.github.com/users/twbs" , username = "twbs" }
    -- , repos = Just [{description = "A free, open source, non-commercial home for musicians and their music", forksCount = 0, language = "Ruby", name = "alonetone", openIssuesCount = 0, starCount = 0}]
    -- , activity = Just {activityType = "PushEvent", createdAt = "2022-04-10T19:17:06Z"}
    , profile = Nothing
    }



-- UPDATE


type Msg
    = UpdateSearchBox String
    | Search
    | LoadProfile (Result Http.Error Profile)
    | LoadRepos (Result Http.Error (List Repo))
    | LoadActivity (Result Http.Error (Maybe Activity))
    | FocusEvent (Result Dom.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchBox input ->
            ( { model | searchText = input }
            , Cmd.none
            )

        Search ->
            ( { model | searchText = "", profile = Nothing, error = Nothing, loading = True }
            , Cmd.batch
                [ fetchProfile model.searchText model.environment
                , fetchRepos model.searchText model.environment
                , fetchActivity model.searchText model.environment
                , Dom.blur "username-input" |> Task.attempt FocusEvent
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
            ( { model | profile = setProfileRepos model.profile repos, loading = False }
            , Cmd.none
            )

        LoadRepos (Err error) ->
            ( { model | error = Just error, loading = False }
            , Cmd.none
            )

        LoadActivity (Ok (Just activity)) ->
            ( { model | profile = setProfileActivity model.profile activity }
            , Cmd.none
            )

        LoadActivity (Ok Nothing) ->
            ( model, Cmd.none )

        LoadActivity (Err error) ->
            ( { model | error = Just error, loading = False }
            , Cmd.none
            )

        FocusEvent result ->
            case result of
                Err (Dom.NotFound _) ->
                    ( model, Cmd.none )

                Ok () ->
                    ( model, Cmd.none )


setProfileRepos : Maybe Profile -> List Repo -> Maybe Profile
setProfileRepos maybeProfile reposList =
    let
        repos =
            if List.isEmpty reposList then
                Nothing

            else
                Just reposList
    in
    Maybe.map (\profile -> { profile | repos = repos }) maybeProfile


setProfileActivity : Maybe Profile -> Activity -> Maybe Profile
setProfileActivity maybeProfile activity =
    Maybe.map (\profile -> { profile | activity = Just activity }) maybeProfile


fetchProfile : String -> String -> Cmd Msg
fetchProfile usernameSearch environment =
    Http.request
        { method = "GET"
        , headers = []
        , url = baseUrl environment ++ usernameSearch
        , body = Http.emptyBody
        , expect = Http.expectJson LoadProfile profileDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


fetchRepos : String -> String -> Cmd Msg
fetchRepos usernameSearch environment =
    Http.request
        { method = "GET"
        , headers = []
        , url = baseUrl environment ++ usernameSearch ++ "/repos"
        , body = Http.emptyBody
        , expect = Http.expectJson LoadRepos (list repoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


fetchActivity : String -> String -> Cmd Msg
fetchActivity usernameSearch environment =
    Http.request
        { method = "GET"
        , headers = []
        , url = baseUrl environment ++ usernameSearch ++ "/last_activity"
        , body = Http.emptyBody
        , expect = Http.expectJson LoadActivity activityDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


baseUrl : String -> String
baseUrl environment =
    if environment == "production" then
        "/.netlify/functions/server/user/"

    else
        "http://localhost:3000/.netlify/functions/server/user/"


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
        |> hardcoded Nothing
        |> hardcoded Nothing


repoDecoder : Decoder Repo
repoDecoder =
    succeed Repo
        |> required "name" string
        |> optional "description" string ""
        |> optional "language" string ""
        |> required "stargazers_count" int
        |> required "forks" int
        |> required "open_issues_count" int


activityDecoder : Decoder (Maybe Activity)
activityDecoder =
    maybe
        (succeed Activity
            |> required "type" string
            |> required "created_at" string
        )


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
                    , id "username-input"
                    , placeholder "GitHub Username:"
                    , autocomplete False
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
                viewProfile model.profile


viewProfile : Maybe Profile -> Html Msg
viewProfile maybeProfile =
    case maybeProfile of
        Just profile ->
            div [ class "profile" ]
                [ viewProfileSummary profile
                , viewProfileCards profile
                ]

        Nothing ->
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


viewProfileCards : Profile -> Html Msg
viewProfileCards profile =
    div [ class "card-container" ]
        [ viewReposCard profile
        , viewFollowersCard profile
        , viewActivityCard profile
        ]


viewReposCard : Profile -> Html Msg
viewReposCard profile =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ viewReposCardFront profile
            , viewReposCardBack profile.repos
            , span [ class "fa fa-rotate" ] []
            ]
        ]


viewReposCardFront : Profile -> Html Msg
viewReposCardFront profile =
    div [ class "card-front" ]
        [ span [ class "fa fa-code card-icon" ] []
        , div [ class "card-label" ] [ text "Number of repos" ]
        , div [ class "card-stat" ] [ text (String.fromInt profile.repo_count) ]
        , div [ class "card-label" ] [ text "Number of gists" ]
        , div [ class "card-stat" ] [ text (String.fromInt profile.gists) ]
        ]


viewReposCardBack : Maybe (List Repo) -> Html Msg
viewReposCardBack maybeRepos =
    case maybeRepos of
        Just repos ->
            let
                mostUsedLanguageTuple =
                    RepoStats.mostUsedLanguage repos

                mostUsedLanguage =
                    Tuple.first mostUsedLanguageTuple

                mostUsedLanguageCount =
                    Tuple.second mostUsedLanguageTuple
            in
            div [ class "card-back" ]
                [ span [ class "fa fa-language card-icon" ] []
                , div [ class "card-label" ] [ text "Most used language" ]
                , div [ class "card-stat" ] [ text mostUsedLanguage ]
                , div [ class "card-label" ] [ text ("Number of " ++ mostUsedLanguage ++ " repos") ]
                , div [ class "card-stat" ] [ text (String.fromInt mostUsedLanguageCount) ]
                ]

        Nothing ->
            div [ class "card-back" ]
                [ span [ class "fa fa-exclamation-circle card-icon" ] []
                , text "No repository data available"
                ]


viewFollowersCard : Profile -> Html Msg
viewFollowersCard profile =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ viewFollowersCardFront profile
            , viewFollowersCardBack profile.repos
            , span [ class "fa fa-rotate" ] []
            ]
        ]


viewFollowersCardFront : Profile -> Html Msg
viewFollowersCardFront profile =
    div [ class "card-front" ]
        [ span [ class "fa fa-user-group card-icon" ] []
        , div [ class "card-label" ] [ text "Followers" ]
        , div [ class "card-stat" ] [ text (String.fromInt profile.followers) ]
        , div [ class "card-label" ] [ text "Following" ]
        , div [ class "card-stat" ] [ text (String.fromInt profile.following) ]
        ]


viewFollowersCardBack : Maybe (List Repo) -> Html Msg
viewFollowersCardBack maybeRepos =
    case maybeRepos of
        Just repos ->
            div [ class "card-back" ]
                [ span [ class "fa fa-star card-icon" ] []
                , div [ class "card-label" ] [ text "Repo Stars" ]
                , div [ class "card-stat" ] [ text (RepoStats.totalStars repos) ]
                , div [ class "card-label" ] [ text "Repo Forks" ]
                , div [ class "card-stat" ] [ text (RepoStats.totalForks repos) ]
                ]

        Nothing ->
            div [ class "card-back" ]
                [ span [ class "fa fa-exclamation-circle card-icon" ] []
                , text "No repository data available"
                ]


viewActivityCard : Profile -> Html Msg
viewActivityCard profile =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ viewActivityCardFront profile
            , viewActivityCardBack profile.activity
            , span [ class "fa fa-rotate" ] []
            ]
        ]


viewActivityCardFront : Profile -> Html Msg
viewActivityCardFront profile =
    div [ class "card-front" ]
        [ span [ class "fa fa-clock card-icon" ] []
        , div [ class "card-label" ] [ text "Account active since" ]
        , div [ class "card-stat date-text" ] [ text (String.left 10 profile.createdAt) ]
        , div [ class "card-stat time-text" ] [ text (String.slice 11 16 profile.createdAt) ]
        ]


viewActivityCardBack : Maybe Activity -> Html Msg
viewActivityCardBack maybeActivity =
    case maybeActivity of
        Just activity ->
            div [ class "card-back" ]
                [ span [ class "fa fa-clock card-icon" ] []
                , div [ class "card-label" ] [ text "Last activity" ]
                , div [ class "card-stat date-text" ] [ text (String.left 10 activity.createdAt) ]
                , div [ class "card-stat time-text" ] [ text (String.slice 11 16 activity.createdAt) ]
                , div [ class "card-label" ] [ text "Activity type" ]
                , div [ class "card-stat date-text" ] [ text activity.activityType ]
                ]

        Nothing ->
            div [ class "card-back" ]
                [ span [ class "fa fa-exclamation-circle card-icon" ] []
                , text "No activity data available"
                ]
