module Main exposing (..)

import Types exposing (..)
import Views
import Network
import Set
import Navigation
import Task
import Time


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { history = [ location ]
      , discs = []
      , owners = []
      , filterText = ""
      , filterOwners = []
      , error = ""
      , pending = Disc "" "" "" 0 False 0
      , latestEdit = 0
      }
    , Network.getDiscs
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetEditTime time ->
            ( { model | latestEdit = (round (time / 1000)) }
            , Navigation.newUrl "#edit"
            )

        SetTime time ->
            ( { model | latestEdit = round (time / 1000) }, Cmd.none )

        UrlChange location ->
            ( { model | history = location :: model.history }, Cmd.none )

        FilterOwner owner ->
            let
                newValue =
                    owner :: model.filterOwners
            in
                ( { model | filterOwners = newValue }, Cmd.none )

        UnfilterOwner owner ->
            let
                newOwners =
                    List.filter (\x -> x /= owner) model.filterOwners
            in
                ( { model | filterOwners = newOwners }, Cmd.none )

        FilterTitle title ->
            ( { model | filterText = title }, Cmd.none )

        JsonResponse (Ok discList) ->
            let
                ownerList =
                    discList
                        |> List.map (\disc -> disc.owner)
                        |> Set.fromList
                        |> Set.toList
            in
                ( { model
                    | discs = discList
                    , owners = ownerList
                  }
                , Task.perform SetTime Time.now
                )

        JsonResponse (Err err) ->
            ( { model | error = (toString err) }, Cmd.none )

        InsertPending (Ok latestID) ->
            case latestID of
                0 ->
                    ( { model | error = "Failed to insert" }, Cmd.none )

                _ ->
                    let
                        pending =
                            model.pending

                        newDiscs =
                            { pending
                                | id = latestID
                                , date = model.latestEdit
                            }
                                :: model.discs

                        newPending =
                            Disc "" "" "" 0 False model.latestEdit
                    in
                        ( { model
                            | pending = newPending
                            , discs = newDiscs
                          }
                        , Navigation.newUrl "#list"
                        )

        InsertPending (Err err) ->
            ( { model | error = (toString err) }, Cmd.none )

        EditPending (Err err) ->
            ( { model | error = (toString err) }, Cmd.none )

        EditPending (Ok status) ->
            case status of
                0 ->
                    ( { model | error = "Failed to edit" }, Cmd.none )

                _ ->
                    let
                        newPending =
                            Disc "" "" "" 0 False

                        editedID =
                            model.pending.id

                        replaceFunc disc =
                            if disc.id == editedID then
                                let
                                    pendingField =
                                        model.pending
                                in
                                    { pendingField | date = model.latestEdit }
                            else
                                disc

                        newDiscs =
                            List.map replaceFunc model.discs
                    in
                        ( { model
                            | discs = newDiscs
                          }
                        , Navigation.newUrl "#list"
                        )

        UpdatePending attribute ->
            let
                pendingField =
                    model.pending
            in
                case attribute of
                    Title newTitle ->
                        ( { model
                            | pending =
                                { pendingField | title = newTitle }
                          }
                        , Cmd.none
                        )

                    Format newFormat ->
                        ( { model
                            | pending =
                                { pendingField | format = newFormat }
                          }
                        , Cmd.none
                        )

                    Owner newOwner ->
                        ( { model
                            | pending =
                                { pendingField | owner = newOwner }
                          }
                        , Cmd.none
                        )

                    Completed ->
                        let
                            newStatus =
                                not model.pending.completed
                        in
                            ( { model
                                | pending =
                                    { pendingField | completed = newStatus }
                              }
                            , Cmd.none
                            )

                    Date date ->
                        ( { model
                            | pending =
                                { pendingField | date = date }
                          }
                        , Cmd.none
                        )

        InsertSignal ->
            ( model, Network.insertAction model.pending )

        EditSignal ->
            ( model, Network.editAction model.pending )

        DeleteSignal ->
            ( model, Network.deleteAction model.pending )

        DeletePending (Err err) ->
            ( { model | error = (toString err) }, Cmd.none )

        DeletePending (Ok id) ->
            let
                newDiscs =
                    List.filter (\disc -> disc.id /= id) model.discs
            in
                ( { model | discs = newDiscs }, Navigation.newUrl "#list" )

        Edit disc ->
            ( { model | pending = disc }, Task.perform SetEditTime Time.now )


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { update = update
        , view = Views.mainView
        , init = init
        , subscriptions = \_ -> Sub.none
        }
