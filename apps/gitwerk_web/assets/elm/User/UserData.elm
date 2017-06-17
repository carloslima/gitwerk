module User.UserData exposing (..)

import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)



type alias User =
    { email : String
    , token : AuthToken
    , username : Username
    }


type Username
    = Username String

type AuthToken
    = AuthToken String

authTokenDecoder : Decoder AuthToken
authTokenDecoder =
    Decode.string
        |> Decode.map AuthToken

decoder : Decoder User
decoder =
    decode User
        |> required "email" Decode.string
        |> required "token" authTokenDecoder
        |> required "username" usernameDecoder

usernameDecoder : Decoder Username
usernameDecoder =
    Decode.map Username Decode.string

decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
    |> Decode.decodeValue Decode.string
    |> Result.toMaybe
    |> Maybe.andThen (Decode.decodeString decoder >> Result.toMaybe)

