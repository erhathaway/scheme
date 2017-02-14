module Cli (
  cliIface
) where

import Eval -- evalFile :: T.Text -> IO ()
import Repl -- Repl.mainLoop :: IO ()
import System.Directory
import Data.Text.IO as TIO
import Options.Applicative

-- SOURCES
--http://book.realworldhaskell.org/read/io.html
-- https://github.com/pcapriotti/optparse-applicative
-- https://hackage.haskell.org/package/optparse-applicative

runScript ::  FilePath -> IO ()
runScript fname = do
  exists <- doesFileExist fname
  if exists
  then TIO.readFile fname >>= evalFile
  else TIO.putStrLn "File does not exist."

data LineOpts = UseReplLineOpts | RunScriptLineOpts String

parseLineOpts :: Parser LineOpts
parseLineOpts = runScriptOpt <|> runReplOpt
  where
    runScriptOpt =
      RunScriptLineOpts <$> strOption (long "script"
                                       <> short 's'
                                       <> metavar "SCRIPT"
                                       <> help "File containing the script you want to run")
    runReplOpt =
      UseReplLineOpts <$ flag' () (long "repl"
                                   <> short 'r'
                                   <> help "Run as interavtive read/evaluate/print/loop")

schemeEntryPoint :: LineOpts -> IO ()
schemeEntryPoint UseReplLineOpts = Repl.mainLoop --repl
schemeEntryPoint (RunScriptLineOpts script) = runScript script

cliIface :: IO ()
cliIface = execParser opts >>= schemeEntryPoint
  where
    opts = info (helper <*> parseLineOpts)
      ( fullDesc
     <> header "Executable binary for Write You A Scheme v2.0"
     <> progDesc "contains an entry point for both running scripts and repl" )
