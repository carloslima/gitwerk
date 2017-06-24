module User.UserRequest exposing (register, storeSession, login)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import User.UserData as User exposing (User)
import Helpers.Ports as Ports


apiUrl end =
    "http://localhost:4000/api/v1/" ++ end


register : { r | username : String, email : String, password : String } -> Http.Request User
register { username, email, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "email" => Encode.string email
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
        User.decoder
            |> Http.post (apiUrl "/users") body

login : {r | username: String, password: String} -> Http.Request User
login { username, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
        User.decoder
            |> Http.post (apiUrl "/sessions") body


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession
