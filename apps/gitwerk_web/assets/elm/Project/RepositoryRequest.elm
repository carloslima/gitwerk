module Project.RepositoryRequest exposing (new)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)

import Util exposing ((=>))
import Util exposing ((=>))
import Project.RepositoryData as Repository exposing (Repository)
import User.UserData exposing (JWTAuthToken)
import User.SessionData exposing (withAuthorization)


apiUrl end =
    "http://localhost:4000/api/v1/" ++ end


new : { r | namespace: String, name : String, privacy : String } -> Maybe JWTAuthToken -> Http.Request Repository
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
       |> HttpBuilder.toRequest
