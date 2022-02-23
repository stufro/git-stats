module Main exposing (..)

import Browser exposing (element)
import Html exposing (..)
import Html.Attributes exposing (class, id, value)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (request)
import Json.Decode exposing (Decoder, string, int, succeed)
import Json.Decode.Pipeline exposing (required, optional)

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
    , profile = Nothing
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
            ( { model | searchText = "" }
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
    div []
        [ h1 [] [ text "Git Stats" ]
        , form [ onSubmit Search ]
            [ input
                [ onInput UpdateSearchBox
                , value model.searchText
                ]
                []
            ]
        ]
