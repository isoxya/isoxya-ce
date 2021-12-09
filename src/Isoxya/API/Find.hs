module Isoxya.API.Find (
    fCrawl,
    fCrawls,
    fProcessor,
    fProcessorHref,
    fProcessors,
    fSite,
    fSites,
    fStreamer,
    fStreamerHref,
    fStreamers,
    ) where


import           Isoxya.API.Auth
import           Isoxya.API.Href
import           Snap.Core                       hiding (pass)
import           TiredPixel.Common.Snap.CoreUtil
import qualified Isoxya.DB                       as D


fCrawl :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m ((D.Site, D.Crawl), D.CrawlId)
fCrawl AR d = do
    (st, stId) <- fSite AR d
    Just stV_ <- lift $ getParam "site_v"
    Just stV <- return $ toRouteId stV_
    Just crl <- D.rCrawl (stId, stV) d
    return ((st, crl), (D.crawlSiteId crl, D.crawlSiteV crl))
fCrawl AW _ = fail "fCrawl/AW not allowed"

fCrawls :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m (D.Site, D.SiteId)
fCrawls _ = fSite AR

fProcessor :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m (D.Processor, D.ProcessorId)
fProcessor _ d = do
    Just proId_ <- lift $ getParam "processor_id"
    Just proId <- return $ toRouteId proId_
    Just pro <- D.rProcessor proId d
    return (pro, D.processorId pro)

fProcessorHref :: MonadSnap m =>
    Maybe ProcessorHref -> APerm -> D.Conn ->
    MaybeT m (D.Processor, D.ProcessorId)
fProcessorHref proH _ d = do
    Just proId <- return $ fromRouteHref =<< proH
    Just pro <- D.rProcessor proId d
    return (pro, D.processorId pro)

fProcessors :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m ()
fProcessors _ _ = pass

fSite :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m (D.Site, D.SiteId)
fSite AR d = do
    Just stURL_ <- lift $ getParam "site_id"
    Just stURL <- return $ toRouteId stURL_
    Just st <- D.rSite stURL d
    return (st, D.siteId st)
fSite AW _ = fail "fSite/AW not allowed"

fSites :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m ()
fSites AR _ = fail "fSites/AR not allowed"
fSites AW _ = pass

fStreamer :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m (D.Streamer, D.StreamerId)
fStreamer _ d = do
    Just strId_ <- lift $ getParam "streamer_id"
    Just strId <- return $ toRouteId strId_
    Just str <- D.rStreamer strId d
    return (str, D.streamerId str)

fStreamerHref :: MonadSnap m =>
    Maybe StreamerHref -> APerm -> D.Conn -> MaybeT m (D.Streamer, D.StreamerId)
fStreamerHref strH _ d = do
    Just strId <- return $ fromRouteHref =<< strH
    Just str <- D.rStreamer strId d
    return (str, D.streamerId str)

fStreamers :: MonadSnap m =>
    APerm -> D.Conn -> MaybeT m ()
fStreamers _ _ = pass
