module Helpers.Request.ErrorsData exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional)
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Dict exposing (Dict)


httpErrorToList : String -> Http.Error -> Decoder (List String) -> List String
httpErrorToList action error errorsDecoder =
    let
        defaultErrorMessage =
            [ "unable to process " ++ action ]
    in
        case error of
            Http.BadStatus response ->
                if response.status.code == 422 then
                    response.body
                        |> decodeString (field "errors" errorsDecoder)
                        |> Result.withDefault []
                else
                    defaultErrorMessage

            _ ->
                defaultErrorMessage


httpErrorToList2 : String -> Http.Error -> Decoder (List ( String, List String )) -> Dict String (List String)
httpErrorToList2 action error errorsDecoder =
    let
        defaultErrorMessage =
            [ ( "default_error", [ "unable to process " ++ action ] ) ]
    in
        case error of
            Http.BadStatus response ->
                if response.status.code == 422 then
                    response.body
                        |> decodeString (field "errors" errorsDecoder)
                        |> Result.withDefault []
                        |> Dict.fromList
                else
                    defaultErrorMessage
                        |> Dict.fromList

            _ ->
                defaultErrorMessage
                    |> Dict.fromList


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
        optional fieldName (Decode.list (Decode.map errorToString string)) []
