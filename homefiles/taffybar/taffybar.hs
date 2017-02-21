import System.Taffybar

import System.Taffybar.MPRIS2
import System.Taffybar.Pager
import System.Taffybar.SimpleClock
import System.Taffybar.WorkspaceHUD
import System.Taffybar.Systray
import System.Taffybar.Battery
import System.Taffybar.TaffyPager
import System.Taffybar.NetMonitor

import System.Taffybar.Widgets.PollingGraph

import System.Information.Memory
import System.Information.CPU

memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (_, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

myPagerConfig :: PagerConfig
myPagerConfig = defaultPagerConfig { activeWorkspace =
                                     colorize "yellow" "" . wrap " [" "] " . escape
                                   , hiddenWorkspace  = wrap " " " " . escape
                                   }

myNetFormat :: String
myNetFormat = "▼ $inKB$kb/s   ▲ $outKB$kb/s"

main = do
  let memCfg = defaultGraphConfig { graphDataColors = [(1, 0, 0, 1)]
                                  , graphLabel = Just "mem"
                                  }
      cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  }
  let clock = textClockNew Nothing "%a %b %_d %r" 1
      pagerConfig = defaultPagerConfig
      mpris = mpris2New
      mem = pollingGraphNew memCfg 1 memCallback
      cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
      tray = systrayNew
      batt  = batteryBarNew defaultBatteryConfig 30
      hudConfig = defaultWorkspaceHUDConfig { underlineHeight = 3
                                            , minWSWidgetSize = Just 50
                                            , showWorkspaceFn = hideEmpty
                                            }
      wnet = netMonitorNewWith 10 "wlp8s0" 1 myNetFormat
      enet = netMonitorNewWith 10 "enp9s0" 1 myNetFormat
      hud = taffyPagerHUDNew myPagerConfig hudConfig

  defaultTaffybar defaultTaffybarConfig { startWidgets = [ hud ]
                                        , endWidgets = [ tray
                                                       , clock
                                                       , mem
                                                       , cpu
                                                       , batt
                                                       , enet
                                                       , wnet
                                                       , mpris]
                                        , monitorNumber = 1
                                        , barPosition = Top
                                        , barHeight = 30
                                        }

-- Local Variables:
-- flycheck-ghc-args: ("-Wno-missing-signatures")
-- End:
