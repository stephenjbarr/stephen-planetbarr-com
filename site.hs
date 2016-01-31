--------------------------------------------------------------------------------
{-# LANGUAGE Arrows             #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
module Main (main) where


--------------------------------------------------------------------------------
import           Data.Monoid         (mconcat, (<>))
import           Data.List           (sort)
import           Prelude             hiding (id)
import           System.Process      (system)
import           System.FilePath     (replaceExtension, takeDirectory)
import qualified Text.Pandoc         as Pandoc


--------------------------------------------------------------------------------
import           Hakyll


--------------------------------------------------------------------------------
-- | Entry point
main :: IO ()
main = hakyllWith config $ do
    -- Static files
    match ("images/*.jpg" .||. "images/*.png" .||. "images/*.gif" .||.
            "favicon.ico" .||. "files/**"     .||. "video/*.webm" .||.
            "video/*.png" .||. "video/*.html" .||. "js/*") $ do
        route   idRoute
        compile copyFileCompiler




    -- Formula images
    -- match "images/*.tex" $ do
    --     route   $ setExtension "png"
    --     compile $ getResourceBody
    --         >>= loadAndApplyTemplate "templates/formula.tex" defaultContext
    --         >>= xelatex >>= pdfToPng

    -- Compress CSS
    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    -- Render the /tmp index page
    match "tmp/index.html" $ do
        route idRoute
        compile $ getResourceBody >>= relativizeUrls

    -- Build tags
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Render each and every markdown post
    match "posts/*.markdown" $ do
        route   $ setExtension ".html"
        compile $ do
            pandocCompiler
                >>= saveSnapshot "content"
                >>= return . fmap demoteHeaders
                >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
                >>= loadAndApplyTemplate "templates/content.html" defaultContext
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Render the html posts. By using getResourceBody, we keep the custom tags
    -- we set using org-mode
    match "posts/*.html" $ do
        route idRoute
        compile $ getResourceBody
          >>= saveSnapshot "content"
          >>= return . fmap demoteHeaders
          >>= loadAndApplyTemplate "templates/post.html"    (postCtx tags)
          >>= loadAndApplyTemplate "templates/content.html" defaultContext
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls

    -- Copy any org-mode files directly, so that people can view the org-source
    -- if they would like.
    -- Need to fix once I figure out https://github.com/jaspervdj/hakyll/issues/338
    -- match "posts/*.org" $ do
    --     route   idRoute
    --     compile copyFileCompiler


    -- Post list
    create ["posts.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx = constField "title" "Posts" <>
                        listField "posts" (postCtx tags) (return posts) <>
                        defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/content.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Post tags
    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged " ++ tag

        -- Copied from posts, need to refactor
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title <>
                        listField "posts" (postCtx tags) (return posts) <>
                        defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/content.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

        -- Create RSS feed as well
        version "rss" $ do
            route   $ setExtension "xml"
            compile $ loadAllSnapshots pattern "content"
                >>= fmap (take 10) . recentFirst
                >>= renderRss (feedConfiguration title) feedCtx

    -- Index
    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*"
            let indexContext =
                    listField "posts" (postCtx tags) (return posts) <>
                    field "tags" (\_ -> renderTagList tags) <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexContext
                >>= loadAndApplyTemplate "templates/content.html" indexContext
                >>= loadAndApplyTemplate "templates/default.html" indexContext
                >>= relativizeUrls

    -- Read templates
    match "templates/*" $ compile $ templateCompiler

    -- Render some static pages
    -- match (fromList pages) $ do
    --     route   $ setExtension ".html"
    --     compile $ pandocCompiler
    --         >>= loadAndApplyTemplate "templates/content.html" defaultContext
    --         >>= loadAndApplyTemplate "templates/default.html" defaultContext
    --         >>= relativizeUrls

    -- Render some static html pages
    match (fromList pages) $ do
        route idRoute
        compile $ getResourceBody
          -- >>= saveSnapshot "content"
          -- >>= return . fmap demoteHeaders
          >>= loadAndApplyTemplate "templates/post.html"    (postCtx tags)
          >>= loadAndApplyTemplate "templates/content.html" defaultContext
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls



    -- Render the 404 page, we don't relativize URL's here.
    match "404.html" $ do
        route idRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/content.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext

    -- Render RSS feed
    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            loadAllSnapshots "posts/*" "content"
                >>= fmap (take 10) . recentFirst
                >>= renderRss (feedConfiguration "All posts") feedCtx

    -- CV as HTML
    match "cv.markdown" $ do
        route   $ setExtension ".html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/cv.html"      defaultContext
            >>= loadAndApplyTemplate "templates/content.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- CV as PDF
    match "cv.markdown" $ version "pdf" $ do
        route   $ setExtension ".pdf"
        compile $ do getResourceBody
            >>= readPandoc
            >>= (return . fmap writeXeTex)
            >>= loadAndApplyTemplate "templates/cv.tex" defaultContext
            >>= xelatex

    -- Photographs
    match "photos/*.jpg" $ do
        route   idRoute
        compile copyFileCompiler

    -- Photography portfolio
    photoBlog <- buildPaginateWith
        (return . map return . sort)
        "photos/*.jpg"
        (\n -> if n == 1
            then "photos.html"
            else fromCapture "photos/*.html" (show n))
    paginateRules photoBlog $ \pageNum pattern -> do
        -- Copied from posts, need to refactor
        route idRoute
        compile $ do
            photos <- loadAll pattern  -- Should be just one
            let paginateCtx = paginateContext photoBlog pageNum
            let ctx         =
                    constField "title" "Photos"                        <>
                    listField "photos"
                        (photographCtx <> paginateCtx) (return photos) <>
                    paginateCtx                                        <>
                    defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/photo.html"   ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
  where
    pages =
        [ "contact.html",
          "bio.html",
          "research/main.html"
        -- , "links.markdown"
        ]

    writeXeTex =
        Pandoc.writeLaTeX Pandoc.def {Pandoc.writerTeXLigatures = False}


--------------------------------------------------------------------------------
postCtx :: Tags -> Context String
postCtx tags = mconcat
    [ modificationTimeField "mtime" "%U"
    , dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]


--------------------------------------------------------------------------------
feedCtx :: Context String
feedCtx = mconcat
    [ bodyField "description"
    , defaultContext
    ]


--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration
    { deployCommand = "aws --profile=sjbai1 s3 sync  /home/stevejb/Blog/stephen-barr-hakyll-bootstap-blog/_site/ \
                       \s3://stephen-staging.barr-ai.labs.com --acl public-read "
    }
    -- The line style here is a "multiline literal":
    -- http://book.realworldhaskell.org/read/characters-strings-and-escaping-rules.html.
    -- Start with a \ at the end of the line, then 


--------------------------------------------------------------------------------
feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration
    { feedTitle       = "Stephen J. Barr - " ++ title
    , feedDescription = "Personal blog of Stephen J. Barr"
    , feedAuthorName  = "Stephen J. Barr"
    , feedAuthorEmail = "stephen@planetbarr.com"
    , feedRoot        = "http://stephen.planetbarr.com"
    }


--------------------------------------------------------------------------------
-- | Hacky.
xelatex :: Item String -> Compiler (Item TmpFile)
xelatex item = do
    TmpFile texPath <- newTmpFile "xelatex.tex"
    let tmpDir  = takeDirectory texPath
        pdfPath = replaceExtension texPath "pdf"

    unsafeCompiler $ do
        writeFile texPath $ itemBody item
        _ <- system $ unwords ["xelatex", "-halt-on-error",
            "-output-directory", tmpDir, texPath, ">/dev/null", "2>&1"]
        return ()

    makeItem $ TmpFile pdfPath


--------------------------------------------------------------------------------
pdfToPng :: Item TmpFile -> Compiler (Item TmpFile)
pdfToPng item = do
    let TmpFile pdfPath = itemBody item
        pngPath         = replaceExtension pdfPath "png"
    unsafeCompiler $ do
        _ <- system $ unwords ["convert", "-density", "150", "-quality", "90",
                pdfPath, pngPath]
        return ()
    makeItem $ TmpFile pngPath


--------------------------------------------------------------------------------
photographCtx :: Context CopyFile
photographCtx = mconcat
    [ urlField "url"
    , dateField "date" "%B %e, %Y"
    , metadataField
    ]
