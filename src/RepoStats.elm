module RepoStats exposing (..)

import List.Extra as LE
import Dict exposing (..)

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
  |> List.map ( \repo -> repo.starCount )
  |> List.foldr (+) 0
  |> String.fromInt

totalForks : List Repo -> String
totalForks repos =
  repos
  |> List.map ( \repo -> repo.forksCount )
  |> List.foldr (+) 0
  |> String.fromInt

mostUsedLanguage : List Repo -> String
mostUsedLanguage repos =
  repos
  |> languageCounts
  |> Tuple.first

mostUsedLanguageCount : List Repo -> String
mostUsedLanguageCount repos =
  repos
  |> languageCounts
  |> Tuple.second
  |> String.fromInt

-- for the number of repos that use the mostUsedLanguage just do the same as above and do Tuple.second

languageCounts : List Repo -> ( String, Int )
languageCounts repos =
  repos
  |> List.map ( \repo -> repo.language )
  |> List.foldr (\language -> Dict.insert language (languageCount language repos)) Dict.empty
  |> Dict.toList
  |> LE.maximumBy (\(language,count) -> count)
  |> Maybe.withDefault ("", 0)

languageCount : String -> List Repo -> Int
languageCount language repos = 
  repos
  |> List.map ( \repo -> repo.language )
  |> LE.count ((==) language)
