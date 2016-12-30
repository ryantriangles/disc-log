module Types exposing (..)

import Http
import Navigation
import Time


type DiscAttribute
    = Owner String
    | Title String
    | Format String
    | Completed
    | Date Int


type alias Disc =
    { owner : String
    , title : String
    , format : String
    , id : Int
    , completed : Bool
    , date : Int
    }


type alias Model =
    { history : List Navigation.Location
    , discs : List Disc
    , owners : List String
    , filterText : String
    , filterOwners : List String
    , error : String
    , pending : Disc
    , latestEdit : Int
    }


type Msg
    = FilterOwner String
    | FilterTitle String
    | UnfilterOwner String
    | JsonResponse (Result Http.Error (List Disc))
    | InsertSignal
    | InsertPending (Result Http.Error Int)
    | UpdatePending DiscAttribute
    | UrlChange Navigation.Location
    | EditSignal
    | Edit Disc
    | SetEditTime Time.Time
    | EditPending (Result Http.Error Int)
    | DeleteSignal
    | SetTime Time.Time
    | DeletePending (Result Http.Error Int)
