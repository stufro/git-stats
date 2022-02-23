module Main exposing(..)

import Browser exposing (element)
import Html exposing (..)
import Html.Attributes exposing (..)

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

type alias Model =
  { githubPass :  String }

initialModel : Model
initialModel =
  { githubPass = "" }

type Msg =
  NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      NoOp -> ( model, Cmd.none )

view : Model -> Html Msg
view model =
  text "Hello, World!"