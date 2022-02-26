module RepoStatsTests exposing (suite)

import RepoStats exposing(..)
import Test exposing (..)
import Expect
import Dict exposing (..)

suite : Test
suite =
    concat
        [ totalStars
        , totalForks
        , mostUsedLanguage
        , mostUsedLanguageCount
        ]


totalStars : Test
totalStars =
    describe "totalStars"
        [ test "sums the starCount value of all the given repos" <|
            \() ->
              let
                repos =
                  [ ( Repo "" "" "" 4 0 0), ( Repo "" "" "" 5 0 0 ) ]
              in
                  repos
                    |> RepoStats.totalStars
                    |> Expect.equal "9"
        ]

totalForks : Test
totalForks =
    describe "totalForks"
        [ test "sums the starCount value of all the given repos" <|
            \() ->
              let
                repos =
                  [ ( Repo "" "" "" 0 1 0), ( Repo "" "" "" 0 2 0 ) ]
              in
                  repos
                    |> RepoStats.totalForks
                    |> Expect.equal "3"
        ]

mostUsedLanguage : Test
mostUsedLanguage =
    describe "mostUsedLanguage"
        [ test "returns the language that appears most often in the repos" <|
            \() ->
              let
                repos =
                  [ ( Repo "" "" "Ruby" 0 0 0), ( Repo "" "" "Ruby" 0 0 0 ), ( Repo "" "" "Elm" 0 0 0 ) ]
              in
                  repos
                    |> RepoStats.mostUsedLanguage
                    |> Expect.equal "Ruby"
        ]

mostUsedLanguageCount : Test
mostUsedLanguageCount =
    describe "mostUsedLanguageCount"
        [ test "returns the number of times the most used language language appears in the repos" <|
            \() ->
              let
                repos =
                  [ ( Repo "" "" "Ruby" 0 0 0), ( Repo "" "" "Ruby" 0 0 0 ), ( Repo "" "" "Elm" 0 0 0 ) ]
              in
                  repos
                    |> RepoStats.mostUsedLanguageCount
                    |> Expect.equal "2"
        ]

