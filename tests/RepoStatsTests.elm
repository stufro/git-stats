module RepoStatsTests exposing (suite)

import Dict exposing (..)
import Expect
import RepoStats exposing (..)
import Test exposing (..)


suite : Test
suite =
    concat
        [ totalStars
        , totalForks
        , mostUsedLanguage
        ]


totalStars : Test
totalStars =
    describe "totalStars"
        [ test "sums the starCount value of all the given repos" <|
            \() ->
                let
                    repos =
                        [ Repo "" "" "" 4 0 0, Repo "" "" "" 5 0 0 ]
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
                        [ Repo "" "" "" 0 1 0, Repo "" "" "" 0 2 0 ]
                in
                repos
                    |> RepoStats.totalForks
                    |> Expect.equal "3"
        ]


mostUsedLanguage : Test
mostUsedLanguage =
    describe "mostUsedLanguage"
        [ test "returns a tuple of the most used language and how many times it's used" <|
            \() ->
                let
                    repos =
                        [ Repo "" "" "Ruby" 0 0 0, Repo "" "" "Ruby" 0 0 0, Repo "" "" "Elm" 0 0 0 ]
                in
                repos
                    |> RepoStats.mostUsedLanguage
                    |> Expect.equal ( "Ruby", 2 )
        , test "ignores empty string languages" <|
            \() ->
                let
                    repos =
                        [ Repo "" "" "" 0 0 0, Repo "" "" "" 0 0 0, Repo "" "" "Elm" 0 0 0 ]
                in
                repos
                    |> RepoStats.mostUsedLanguage
                    |> Expect.equal ( "Elm", 1 )
        , test "handles an empty list of repos" <|
            \() ->
                let
                    repos =
                        []
                in
                repos
                    |> RepoStats.mostUsedLanguage
                    |> Expect.equal ( "", 0 )
        ]
