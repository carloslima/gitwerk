module Project.RepositoryRequest exposing (new, get, listFiles)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams, withHeader)
import Util exposing ((=>))
import Util exposing ((=>))
import Project.RepositoryData as Repository exposing (Repository)
import Project.FileData as File exposing (File)
import User.UserData exposing (JWTAuthToken)
import User.SessionData exposing (withAuthorization)


apiUrl end =
    "http://localhost:4000/api/v1/" ++ end


new : { r | namespace : String, name : String, privacy : String } -> Maybe JWTAuthToken -> Http.Request Repository
new { namespace, name, privacy } maybeToken =
    let
        repo =
            Encode.object
                [ "name" => Encode.string name
                , "privacy" => Encode.string privacy
                , "namespace" => Encode.string namespace
                ]

        expect =
            Repository.decoder
                |> Http.expectJson

        body =
            Encode.object [ "repository" => repo ]
                |> Http.jsonBody
    in
        apiUrl "repositories"
            |> HttpBuilder.post
            |> withBody body
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> withHeader "Accept" "application/json"
            |> HttpBuilder.toRequest


get : String -> String -> Maybe JWTAuthToken -> Http.Request Repository
get namespace name maybeToken =
    let
        expect =
            Repository.decoder
                |> Http.expectJson
    in
        apiUrl ("users/" ++ namespace ++ "/repositories/" ++ name)
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> withHeader "Accept" "application/json"
            |> HttpBuilder.toRequest


listFiles : { r | namespace : String, name : String } -> Maybe JWTAuthToken -> Http.Request (List File)
listFiles { namespace, name } maybeToken =
    let
        expect =
            File.decoder
                |> Decode.list
                |> Http.expectJson
    in
        apiUrl ("users/" ++ namespace ++ "/repositories/" ++ name ++ "/code/file-list/master")
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> withHeader "Accept" "application/json"
            |> HttpBuilder.toRequest
