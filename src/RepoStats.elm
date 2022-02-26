module RepoStats exposing (..)

import Dict exposing (..)
import List.Extra as LE


type alias Repo =
    { name : String
    , description : String
    , language : String
    , starCount : Int
    , forksCount : Int
    , openIssuesCount : Int
    }


totalStars : List Repo -> String
totalStars repos =
    repos
        |> List.map .starCount
        |> List.foldr (+) 0
        |> String.fromInt


totalForks : List Repo -> String
totalForks repos =
    repos
        |> List.map .forksCount
        |> List.foldr (+) 0
        |> String.fromInt


mostUsedLanguage : List Repo -> ( String, Int )
mostUsedLanguage repos =
    repos
        |> List.map .language
        |> List.filter (\language -> not (language == ""))
        |> List.foldr (\language -> Dict.insert language (languageCount language repos)) Dict.empty
        |> Dict.toList
        |> LE.maximumBy (\( language, count ) -> count)
        |> Maybe.withDefault ( "", 0 )


languageCount : String -> List Repo -> Int
languageCount language repos =
    repos
        |> List.map .language
        |> LE.count ((==) language)
