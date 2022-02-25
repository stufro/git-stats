module Main exposing (..)

import Browser exposing (element)
import Html exposing (..)
import Html.Attributes exposing (class, id, src, value)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (request)
import Json.Decode exposing (Decoder, int, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Html.Attributes exposing (placeholder)


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
    , repos : Int
    , gists : Int
    , followers : Int
    , following : Int
    , createdAt : String
    }


initialModel : Model
initialModel =
    { githubPass = ""
    , searchText = ""
    , error = Nothing
    , profile =
        Just
            { avatarUrl = "https://avatars.githubusercontent.com/u/2918581?v=4"
            , bio = "Source code and more for the most popular front-end framework in the world."
            , blog = "https://getbootstrap.com"
            , company = ""
            , createdAt = "2012-11-29T05:47:03Z"
            , email = ""
            , followers = 0
            , following = 0
            , gists = 0
            , location = "San Francisco"
            , name = "Bootstrap"
            , repos = 24
            , twitterUsername = "getbootstrap"
            , url = "https://api.github.com/users/twbs"
            , username = "twbs"
            }
    }



-- UPDATE


type Msg
    = UpdateSearchBox String
    | Search
    | LoadProfile (Result Http.Error Profile)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchBox input ->
            ( { model | searchText = input }
            , Cmd.none
            )

        Search ->
            ( { model | searchText = "", profile = Nothing }
            , fetchProfile model.searchText model.githubPass
            )

        LoadProfile (Ok profile) ->
            ( { model | profile = Just profile }
            , Cmd.none
            )

        LoadProfile (Err error) ->
            ( { model | error = Just error }
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


authorisationHeader : String -> Http.Header
authorisationHeader password =
    Http.header "Authorization" ("Basic " ++ password)


profileDecoder : Decoder Profile
profileDecoder =
    succeed Profile
        |> required "login" string
        |> required "avatar_url" string
        |> required "url" string
        |> required "name" string
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
        , viewProfile model.profile
        ]


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
        [ div [ class "card" ]
            [ span [ class "fa fa-code card-icon" ] []
            , div [ class "card-label" ] [ text "Number of repos" ]
            , div [ class "card-stat" ] [ text (String.fromInt profile.repos) ]
            , div [ class "card-label" ] [ text "Number of gists" ]
            , div [ class "card-stat" ] [ text (String.fromInt profile.gists) ]
            ]
        , div [ class "card" ]
            [ span [ class "fa fa-user-group card-icon" ] []
            , div [ class "card-label" ] [ text "Followers" ]
            , div [ class "card-stat" ] [ text (String.fromInt profile.followers) ]
            , div [ class "card-label" ] [ text "Following" ]
            , div [ class "card-stat" ] [ text (String.fromInt profile.following) ]
            ]
        , div [ class "card" ]
            [ span [ class "fa fa-clock card-icon" ] []
            , div [ class "card-label" ] [ text "Account active since" ]
            , div [ class "card-stat" ] [ text (String.left 10 profile.createdAt) ]
            ]
        ]
