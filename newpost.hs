{-# LANGUAGE OverloadedStrings, ScopedTypeVariables, GeneralizedNewtypeDeriving #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  newpost
-- Copyright   :  (C) 2015-2016, Stephen J. Barr
-- License     :  None
-- Maintainer  :  Stephen J. Barr <stephen@planetbarr.com>
-- Stability   :  experimental
--
-- Simple script to create stub files necessary for a new post
-- 
----------------------------------------------------------------------------


import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.LocalTime
import Data.Text as T
import Data.Text.Lazy.Builder as T
import Data.Text.Format as T
import qualified Data.Text.IO as T
import qualified TextShow as TS (toText)
import qualified Data.List as L
import qualified Data.HashMap.Strict as H
import Text.Karver



pad2 :: Int -> T.Text
pad2 x =  TS.toText $ left 2 '0' x


datePrefix :: (Integer, Int, Int) -> Text
datePrefix (y_i, m_i, d_i) = T.concat $ L.intersperse "-" [y, m, d] 
  where 
    y = T.pack $ show y_i
    m = pad2 m_i
    d = pad2 d_i


getLocalYMD :: IO (Integer, Int, Int)
getLocalYMD = do
  now <- getCurrentTime
  timezone <- getCurrentTimeZone
  let zoneNow = utcToLocalTime timezone now
  return $ toGregorian $ localDay zoneNow



mkMetadataHashmap :: (Text, Text, Text, Text) -> H.HashMap Text Value
mkMetadataHashmap (title, date, description, tags) = H.fromList $
  [ ("title", Literal title)
  , ("date_ymd", Literal date)
  , ("description", Literal description)
  , ("tags_comma_sep", Literal tags)
  ]

mkPostHashmap :: (Text, Text, Text) -> H.HashMap Text Value
mkPostHashmap (title, date, org_tags) = H.fromList $
  [ ("title", Literal title)
  , ("date_ymd", Literal date)
  , ("org_tags", Literal org_tags)
  ]

csToColonSep :: Text -> Text
csToColonSep = (removeSpc . commaToColon)
  where
    removeSpc    = T.replace " " "" 
    commaToColon = T.replace "," ":" 


mkTitleAbbreviation :: Text -> Text
mkTitleAbbreviation title = dashed_title
  where
    words = T.splitOn " " $ T.toLower title
    start_words = L.take 4 words
    dashed_title = T.concat $ L.intersperse "-" start_words


main :: IO ()
main = do
    putStrLn "New post!!!"
    (year, month, day) <- getLocalYMD
    let date_prefix = datePrefix  (year, month, day)
    

    meta_template <- T.readFile "util_templates/metadata.template"
    post_template <- T.readFile "util_templates/post.template"


    putStrLn "Enter post title:"
    post_title <- getLine
    let post_title_txt = T.pack post_title

    putStrLn "Enter post description:"
    description <- getLine
    let description_txt = T.pack description

    putStrLn "Enter comma separated list of tags:"
    cs_tag_line <- getLine
    let cs_tag_txt = T.pack cs_tag_line
    let org_tags = csToColonSep cs_tag_txt

    let meta_hash_map = mkMetadataHashmap (post_title_txt, date_prefix, description_txt,  cs_tag_txt)
    let post_hash_map = mkPostHashmap (post_title_txt, date_prefix, org_tags)
    let meta_rendered = renderTemplate meta_hash_map meta_template
    let post_rendered = renderTemplate post_hash_map post_template


    let fname_base = T.concat [date_prefix, "-", (mkTitleAbbreviation post_title_txt)]
    let fname_post = T.concat [fname_base, ".org"]
    let fname_meta = T.concat [fname_base, ".html.metadata"]


    putStrLn "----------------------------------------"
    putStrLn $ "FILE: " ++ (T.unpack fname_meta)
    putStr $ T.unpack meta_rendered

    putStrLn ""

    putStrLn "----------------------------------------"
    putStrLn $ "FILE: " ++ (T.unpack fname_post)
    putStr $ T.unpack post_rendered

    putStrLn " "
    putStrLn "Write files? (y/n)"
    output_yn <- getLine
    
    if output_yn == "y"
      then
        do
          T.writeFile (T.unpack fname_post) post_rendered
          T.writeFile (T.unpack fname_meta) meta_rendered
          putStrLn "Files written."
      else
        do 
          putStrLn "Nothing written"
      
    putStrLn "Done."
