module Debugger.Internal.Statement
  ( Line
  , Location(..)
  , Var
  , Expr
  , Id(..)
  , Statement(..)
  ) where

import Data.Text (Text)

type Var = Text  -- TODO different type?

type Expr = Text  -- TODO different type?

-- A unique ID for a breakpoint.
newtype Id = Id Text
  deriving (Eq, Show)

type Line = Int

-- A place to set a breakpoint at.
data Location
  = Function Text
  | File FilePath Line
  deriving Show

-- Main AST data type.
data Statement
  = Break Location
  | Command Id [Statement]
  | Continue
  | Print Expr
  | Set Var Expr
  deriving Show

  {-
type Var = Text

type ShellCommand = Text

data Statement
  = Break Location -- hbreak? conditional breakpoints?
  | Command Id [Statement]
  | Set Var Expr
  | Call Expr
  | Print Expr
  | Printf Text [Expr]
  | Continue
  | Shell ShellCommand
  | Enable Id
  | Disable Id
  | Delete
  | Reset
  | Run
  | Step
  | Next
  | If Expr [Statement]
  -- TODO info b, set logging on (opts), ...
-}
