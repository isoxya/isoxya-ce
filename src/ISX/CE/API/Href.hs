{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}


module ISX.CE.API.Href (
    CrwlHref(..),
    CrwlsHref(..),
    PlugProcHref(..),
    PlugProcsHref(..),
    PlugStrmHref(..),
    PlugStrmsHref(..),
    SiteHref(..),
    ) where


import           Data.Aeson
import           Network.URI
import           TPX.Com.Snap.CoreUtils
import qualified Data.ByteString.Base64.URL as B64
import qualified Data.ByteString.Char8      as C8
import qualified Data.Time.Format           as Time
import qualified Data.UUID                  as UUID
import qualified ISX.CE.DB                  as D
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
newtype CrwlHref = CrwlHref { unCrwlHref :: ByteString
    } deriving (Show)
instance RouteHref CrwlHref (D.SiteURL, D.SiteV) where
    toRouteHref (s, c) = CrwlHref $
        unSiteHref (toRouteHref s) <> crwls <> "/" <> fromRouteId c
    fromRouteHref h = do
        ["", "site", s, "crwl", c] <- return $ C8.split '/' $ unCrwlHref h
        s' <- toRouteId s
        c' <- toRouteId c
        return (s', c')
instance ToJSON CrwlHref where
    toJSON o = toJSON (decodeUtf8 $ unCrwlHref o :: Text)

newtype CrwlsHref = CrwlsHref { unCrwlsHref :: ByteString
    } deriving (Show)
instance RouteHref CrwlsHref D.SiteURL where
    toRouteHref s = CrwlsHref $ unSiteHref (toRouteHref s) <> crwls
    fromRouteHref h = do
        ["", "site", s, "crwl"] <- return $ C8.split '/' $ unCrwlsHref h
        toRouteId s
instance ToJSON CrwlsHref where
    toJSON o = toJSON (decodeUtf8 $ unCrwlsHref o :: Text)

newtype PlugProcHref = PlugProcHref { unPlugProcHref :: ByteString
    } deriving (Show)
instance RouteHref PlugProcHref D.PlugProcId where
    toRouteHref p = PlugProcHref $ plugProcs <> "/" <> fromRouteId p
    fromRouteHref h = do
        ["", "plug_proc", p] <- return $ C8.split '/' $ unPlugProcHref h
        toRouteId p
instance FromJSON PlugProcHref where
    parseJSON = withText "plug_proc.href" $ pure . PlugProcHref . encodeUtf8
instance ToJSON PlugProcHref where
    toJSON o = toJSON (decodeUtf8 $ unPlugProcHref o :: Text)

newtype PlugProcsHref = PlugProcsHref { unPlugProcsHref :: ByteString
    } deriving (Show)
instance RouteHref PlugProcsHref () where
    toRouteHref _ = PlugProcsHref plugProcs
    fromRouteHref h = do
        ["", "plug_proc"] <- return $ C8.split '/' $ unPlugProcsHref h
        pass
instance ToJSON PlugProcsHref where
    toJSON o = toJSON (decodeUtf8 $ unPlugProcsHref o :: Text)

newtype PlugStrmHref = PlugStrmHref { unPlugStrmHref :: ByteString
    } deriving (Show)
instance RouteHref PlugStrmHref D.PlugStrmId where
    toRouteHref p = PlugStrmHref $ plugStrms <> "/" <> fromRouteId p
    fromRouteHref h = do
        ["", "plug_strm", p] <- return $ C8.split '/' $ unPlugStrmHref h
        toRouteId p
instance FromJSON PlugStrmHref where
    parseJSON = withText "plug_strm.href" $ pure . PlugStrmHref . encodeUtf8
instance ToJSON PlugStrmHref where
    toJSON o = toJSON (decodeUtf8 $ unPlugStrmHref o :: Text)

newtype PlugStrmsHref = PlugStrmsHref { unPlugStrmsHref :: ByteString
    } deriving (Show)
instance RouteHref PlugStrmsHref () where
    toRouteHref _ = PlugStrmsHref plugStrms
    fromRouteHref h = do
        ["", "plug_strm"] <- return $ C8.split '/' $ unPlugStrmsHref h
        pass
instance ToJSON PlugStrmsHref where
    toJSON o = toJSON (decodeUtf8 $ unPlugStrmsHref o :: Text)

newtype SiteHref = SiteHref { unSiteHref :: ByteString
    } deriving (Show)
instance RouteHref SiteHref D.SiteURL where
    toRouteHref s = SiteHref $ sites <> "/" <> fromRouteId s
    fromRouteHref h = do
        ["", "site", s] <- return $ C8.split '/' $ unSiteHref h
        toRouteId s
instance ToJSON SiteHref where
    toJSON o = toJSON (decodeUtf8 $ unSiteHref o :: Text)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
crwls :: ByteString
crwls = "/crwl"

plugProcs :: ByteString
plugProcs = "/plug_proc"

plugStrms :: ByteString
plugStrms = "/plug_strm"

sites :: ByteString
sites = "/site"
--------------------------------------------------------------------------------
timeF :: String
timeF = Time.iso8601DateFormat (Just "%T%QZ")
--------------------------------------------------------------------------------
instance RouteId D.PlugProcId where
    toRouteId b = D.PlugProcId <$> UUID.fromASCIIBytes b
    fromRouteId = show . D.unPlugProcId

instance RouteId D.PlugStrmId where
    toRouteId b = D.PlugStrmId <$> UUID.fromASCIIBytes b
    fromRouteId = show . D.unPlugStrmId

instance RouteId D.SiteURL where
    toRouteId b = D.SiteURL <$>
        parseAbsoluteURI (decodeUtf8 $ B64.decodeLenient b)
    fromRouteId = B64.encodeUnpadded . show . D.unSiteURL

instance RouteId D.SiteV where
    toRouteId b = D.SiteV <$>
        Time.parseTimeM False Time.defaultTimeLocale timeF (decodeUtf8 b)
    fromRouteId = encodeUtf8 .
        Time.formatTime Time.defaultTimeLocale timeF . D.unSiteV
