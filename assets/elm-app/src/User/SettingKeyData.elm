module User.SettingKeyData exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias Key =
    { id : String
    , title : String
    }


decoder : Decoder Key
decoder =
    decode Key
        |> required "id" Decode.string
        |> required "title" Decode.string
