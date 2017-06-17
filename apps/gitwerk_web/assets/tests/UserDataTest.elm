module UserDataTest exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, string)
import Main
import User.UserData as User exposing (User, AuthToken, Username)
import Json.Decode
import Json.Encode


suite : Test
suite =
    describe "parse user from json"
        [ test "with a proper json" <|
            \_ ->
                let
                    json =
                        Json.Encode.string """
                    {"username": "sam", "token": "UluC5cgCy2f7KFJVeUIBYkvZE04=", "email" : "sam@example.com"}
                    """

                    token =
                        User.AuthToken "UluC5cgCy2f7KFJVeUIBYkvZE04="

                    username =
                        User.Username "sam"

                    user =
                        User "sam@example.com" token username
                in
                    Expect.equal (Just user) (User.decodeUserFromJson json)
        , test "with an empty string json" <|
            \_ ->
                let
                    json =
                        Json.Encode.string ""
                in
                    Expect.equal Nothing (User.decodeUserFromJson json)
        , test "with missing object" <|
            \_ ->
                let
                    json =
                        Json.Encode.string """
                    {"username": "sam"}
                    """
                in
                    Expect.equal Nothing (User.decodeUserFromJson json)
        ]
