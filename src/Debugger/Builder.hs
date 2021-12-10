-- NOTE: meant to be imported qualified
module Debugger.Builder
  ( Builder
  , runBuilder
  , break
  , command
  , continue
  , print
  , example
  ) where

import Prelude hiding (break, print)
import qualified Data.Text as T
import Control.Monad.State.Strict
import Debugger.Internal.Statement


type Counter = Int

data BuilderState
  = BuilderState
  { stmts :: [Statement]
  , varCounter :: Counter
  }

newtype Builder a
  = Builder (State BuilderState a)
  deriving (Functor, Applicative, Monad, MonadState BuilderState)
  via State BuilderState


runBuilder :: Builder a -> [Statement]
runBuilder = runBuilder' 0

runBuilder' :: Counter -> Builder a -> [Statement]
runBuilder' counter (Builder m) =
  let result = execState m (BuilderState [] counter)
   in reverse $ stmts result

break :: Location -> Builder Id
break loc = do
  emit $ Break loc
  var <- newBreakpointVar
  emit $ Set var "$bpnum"
  pure $ Id var

command :: Id -> Builder () -> Builder ()
command bp cmds = do
  counter <- gets varCounter
  let stmts = runBuilder' counter cmds
  emit $ Command bp stmts

continue :: Builder ()
continue = emit Continue

print :: Expr -> Builder ()
print = emit . Print

-- TODO: add set statement

emit :: Statement -> Builder ()
emit stmt =
  modify $ \s -> s { stmts = stmt : stmts s }

newBreakpointVar :: Builder Var
newBreakpointVar = do
  currentId <- gets varCounter
  modify $ \s -> s { varCounter = varCounter s + 1 }
  pure $ "$var" <> T.pack (show currentId)

example :: Builder ()
example = do
  bp <- break (Function "main")
  command bp $ do
    print "123"

  continue

-- $> runBuilder example
