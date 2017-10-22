module User.SettingRequest exposing (listKeys, newKey)

import User.SettingKeyData as Key exposing (Key)
import User.UserData exposing (JWTAuthToken)
import User.SessionData exposing (withAuthorization)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams, withHeader)
import Json.Decode as Decode
import Util exposing ((=>))
import Json.Encode as Encode


apiUrl end =
    "http://localhost:4000/api/v1/" ++ end


listKeys : String -> Maybe JWTAuthToken -> Http.Request (List Key)
listKeys username maybeToken =
    let
        expect =
            Key.decoder
                |> Decode.list
                |> Http.expectJson
    in
        apiUrl "users/"
            ++ username
            ++ "/keys"
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> withHeader "Accept" "application/json"
            |> HttpBuilder.toRequest


newKey : String -> { r | title : String, key : String } -> Maybe JWTAuthToken -> Http.Request Key
newKey username { title, key } maybeToken =
    let
        key_obj =
            Encode.object
                [ "title" => Encode.string title
                , "key" => Encode.string key
                , "type" => Encode.string "ssh"
                ]

        expect =
            Key.decoder
                |> Http.expectJson

        body =
            Encode.object [ "key" => key_obj ]
                |> Http.jsonBody
    in
        apiUrl "users/" ++ username ++ "/keys"
            |> HttpBuilder.post
            |> withBody body
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> withHeader "Accept" "application/json"
            |> HttpBuilder.toRequest
