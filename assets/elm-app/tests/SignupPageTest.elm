module SignupPageTest exposing (..)

import Test exposing (..)
import Expect
import Http
import User.UserData as User exposing (User)
import User.SignupPage as SignupPage
import Dict
import Debug


anErrorMessage =
    """
{"errors": {"email": ["has already been taken"]}}
"""


apiUrl =
    "http://example.com/api/v1/users"


suite : Test
suite =
    describe "Handles API Signup error messages"
        [ test "handles 422 errors" <|
            \_ ->
                let
                    resp =
                        Http.Response apiUrl { code = 422, message = "Unprocessable Entity" } (Dict.fromList []) anErrorMessage

                    msg =
                        SignupPage.RegisterCompleted (Err (Http.BadStatus resp))

                    model =
                        (SignupPage.Model (Dict.fromList []) "" "" "")

                    update_result =
                        SignupPage.update msg model

                    error_list =
                        [ ( "email", [ "email has already been taken" ] ), ( "password", [] ), ( "username", [] ) ]

                    expected_model =
                        (SignupPage.Model (Dict.fromList error_list) "" "" "")
                in
                    Expect.equal update_result ( ( expected_model, Cmd.none ), SignupPage.NoOp )
        , test "handles other errors" <|
            \_ ->
                let
                    resp =
                        Http.Response apiUrl { code = 500, message = "Unprocessable Entity" } (Dict.fromList []) anErrorMessage

                    msg =
                        SignupPage.RegisterCompleted (Err (Http.BadStatus resp))

                    model =
                        (SignupPage.Model (Dict.fromList []) "" "" "")

                    update_result =
                        SignupPage.update msg model

                    error_list =
                        [("default_error",["unable to process registration"])]

                    expected_model =
                        (SignupPage.Model (Dict.fromList error_list) "" "" "")
                in
                    Expect.equal update_result ( ( expected_model, Cmd.none ), SignupPage.NoOp )
        ]
