module RepoStats exposing (..)

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