//+------------------------------------------------------------------+
//| This MQL is generated by Expert Advisor Builder                  |
//|                http://sufx.core.t3-ism.net/ExpertAdvisorBuilder/ |
//|                                                                  |
//|  In no event will author be liable for any damages whatsoever.   |
//|                      Use at your own risk.                       |
//|                                                                  |
//+------------------- DO NOT REMOVE THIS HEADER --------------------+

#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

extern string Comment_MultiLotsFactor = "Multi Lot Factor:";
extern double MultiLotsFactor = 1.1;
extern double Lots = 0.01;
extern double TakeProfit = 620.0;
extern string Comment_StepLots = "Step Lots:";
extern double StepLots = 310.0;
extern string Comment_UseTrailing = "Use Trailing Stop:";
extern bool UseTrailing = FALSE;
extern string Comment_TrailStart = "TrailStop:";
extern double TrailStart = 10.0;
extern string Comment_TrailStop = "Traling Stop:";
extern double TrailStop = 10.0;
extern string Comment_MaxCountOrders = "Max Count Orders:";
extern int MaxCountOrders = 20;
extern string Comment_SafeEquity = "Safe Equity Risk %";
extern bool SafeEquity = FALSE;
extern double SafeEquityRisk = 20.0;
extern string Comment_slippage = "Slippage";
extern double slippage = 3.0;
extern int MagicNumber = 1;
bool gi_220 = FALSE;
double gd_224 = 48.0;
double g_pips_232 = 500.0;
double gd_240 = 0.0;
bool gi_248 = TRUE;
bool gi_252 = FALSE;
int gi_256 = 1;
double g_price_260;
double gd_268;
double gd_unused_276;
double gd_unused_284;
double g_price_292;
double g_bid_300;
double g_ask_308;
double gd_316;
double gd_324;
double gd_340;
bool gi_348;
string gs_352 = "Auto_Profit";
int g_time_360 = 0;
int gi_364;
int gi_368 = 0;
double gd_372;
int g_pos_380 = 0;
int gi_384;
double gd_388 = 0.0;
bool gi_396 = FALSE;
bool gi_400 = FALSE;
bool gi_404 = FALSE;
int gi_408;
bool gi_412 = FALSE;
int g_datetime_416 = 0;
int g_datetime_420 = 0;
double gd_424;
double gd_432;

int init() {
   gd_340 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   double s=MarketInfo(Symbol(), MODE_MINLOT);
    
   if(s== 0.001)
      gd_240 = 3;
     
   else if(s== 0.01)
      gd_240 = 2;
   else if(s== 0.1)
      gd_240 = 1;
      
   else if(s== 1.0)
      gd_240 = 0;
   
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double l_ord_lots_8;
   double l_ord_lots_16;
   double l_iclose_24;
   double l_iclose_32;
   if (UseTrailing) TrailingAlls(TrailStart, TrailStop, g_price_292);
   if (gi_220) {
      if (TimeCurrent() >= gi_364) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_360 == Time[0]) return (0);
   g_time_360 = Time[0];
   double ld_0 = CalculateProfit();
   if (SafeEquity) {
      if (ld_0 < 0.0 && MathAbs(ld_0) > SafeEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_412 = FALSE;
      }
   }
   gi_384 = CountTrades();
   if (gi_384 == 0) gi_348 = FALSE;
   for (g_pos_380 = OrdersTotal() - 1; g_pos_380 >= 0; g_pos_380--) {
      OrderSelect(g_pos_380, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            gi_400 = TRUE;
            gi_404 = FALSE;
            l_ord_lots_8 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            gi_400 = FALSE;
            gi_404 = TRUE;
            l_ord_lots_16 = OrderLots();
            break;
         }
      }
   }
   if (gi_384 > 0 && gi_384 <= MaxCountOrders) {
      RefreshRates();
      gd_316 = FindLastBuyPrice();
      gd_324 = FindLastSellPrice();
      if (gi_400 && gd_316 - Ask >= StepLots * Point) gi_396 = TRUE;
      if (gi_404 && Bid - gd_324 >= StepLots * Point) gi_396 = TRUE;
   }
   if (gi_384 < 1) {
      gi_404 = FALSE;
      gi_400 = FALSE;
      gi_396 = TRUE;
      gd_268 = AccountEquity();
   }
   if (gi_396) {
      gd_316 = FindLastBuyPrice();
      gd_324 = FindLastSellPrice();
      if (gi_404) {
         if (gi_252) {
            fOrderCloseMarket(0, 1);
            gd_372 = NormalizeDouble(MultiLotsFactor * l_ord_lots_16, gd_240);
         } else gd_372 = fGetLots(OP_SELL);
         if (gi_248) {
            gi_368 = gi_384;
            if (gd_372 > 0.0) {
               RefreshRates();
               gi_408 = OpenPendingOrder(1, gd_372, Bid, slippage, Ask, 0, 0, gs_352 + "-" + gi_368, MagicNumber, 0, HotPink);
               if (gi_408 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_324 = FindLastSellPrice();
               gi_396 = FALSE;
               gi_412 = TRUE;
            }
         }
      } else {
         if (gi_400) {
            if (gi_252) {
               fOrderCloseMarket(1, 0);
               gd_372 = NormalizeDouble(MultiLotsFactor * l_ord_lots_8, gd_240);
            } else gd_372 = fGetLots(OP_BUY);
            if (gi_248) {
               gi_368 = gi_384;
               if (gd_372 > 0.0) {
                  gi_408 = OpenPendingOrder(0, gd_372, Ask, slippage, Bid, 0, 0, gs_352 + "-" + gi_368, MagicNumber, 0, Lime);
                  if (gi_408 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  gd_316 = FindLastBuyPrice();
                  gi_396 = FALSE;
                  gi_412 = TRUE;
               }
            }
         }
      }
   }
   if (gi_396 && gi_384 < 1) {
      l_iclose_24 = iClose(Symbol(), 0, 2);
      l_iclose_32 = iClose(Symbol(), 0, 1);
      g_bid_300 = Bid;
      g_ask_308 = Ask;
      if (!gi_404 && !gi_400) {
         gi_368 = gi_384;
         if (l_iclose_24 > l_iclose_32) {
            gd_372 = fGetLots(OP_SELL);
            if (gd_372 > 0.0) {
               gi_408 = OpenPendingOrder(1, gd_372, g_bid_300, slippage, g_bid_300, 0, 0, gs_352 + " " + MagicNumber + "-" + gi_368, MagicNumber, 0, HotPink);
               if (gi_408 < 0) {
                  Print(gd_372, "Error: ", GetLastError());
                  return (0);
               }
               gd_316 = FindLastBuyPrice();
               gi_412 = TRUE;
            }
         } else {
            gd_372 = fGetLots(OP_BUY);
            if (gd_372 > 0.0) {
               gi_408 = OpenPendingOrder(0, gd_372, g_ask_308, slippage, g_ask_308, 0, 0, gs_352 + " " + MagicNumber + "-" + gi_368, MagicNumber, 0, Lime);
               if (gi_408 < 0) {
                  Print(gd_372, "Error: ", GetLastError());
                  return (0);
               }
               gd_324 = FindLastSellPrice();
               gi_412 = TRUE;
            }
         }
      }
      if (gi_408 > 0) gi_364 = TimeCurrent() + 60.0 * (60.0 * gd_224);
      gi_396 = FALSE;
   }
   gi_384 = CountTrades();
   g_price_292 = 0;
   double ld_40 = 0;
   for (g_pos_380 = OrdersTotal() - 1; g_pos_380 >= 0; g_pos_380--) {
      OrderSelect(g_pos_380, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_292 += OrderOpenPrice() * OrderLots();
            ld_40 += OrderLots();
         }
      }
   }
   if (gi_384 > 0) g_price_292 = NormalizeDouble(g_price_292 / ld_40, Digits);
   if (gi_412) {
      for (g_pos_380 = OrdersTotal() - 1; g_pos_380 >= 0; g_pos_380--) {
         OrderSelect(g_pos_380, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               g_price_260 = g_price_292 + TakeProfit * Point;
               gd_unused_276 = g_price_260;
               gd_388 = g_price_292 - g_pips_232 * Point;
               gi_348 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               g_price_260 = g_price_292 - TakeProfit * Point;
               gd_unused_284 = g_price_260;
               gd_388 = g_price_292 + g_pips_232 * Point;
               gi_348 = TRUE;
            }
         }
      }
   }
   if (gi_412) {
      if (gi_348 == TRUE) {
         for (g_pos_380 = OrdersTotal() - 1; g_pos_380 >= 0; g_pos_380--) {
            OrderSelect(g_pos_380, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) OrderModify(OrderTicket(), g_price_292, OrderStopLoss(), g_price_260, 0, Yellow);
            gi_412 = FALSE;
         }
      }
   }
   return (0);
}

double ND(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int l_pos_12 = OrdersTotal() - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_416 != iTime(NULL, 0, 0)) {
                     g_datetime_416 = iTime(NULL, 0, 0);
                     Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
                     Print("Error close SELL " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_420 != iTime(NULL, 0, 0)) {
                     g_datetime_420 = iTime(NULL, 0, 0);
                     Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8);
}

double fGetLots(int a_cmd_0) {
   double l_lots_4;
   int l_datetime_16;
   switch (gi_256) {
   case 0:
      l_lots_4 = Lots;
      break;
   case 1:
      l_lots_4 = NormalizeDouble(Lots * MathPow(MultiLotsFactor, gi_368), gd_240);
      break;
   case 2:
      l_datetime_16 = 0;
      l_lots_4 = Lots;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (l_datetime_16 < OrderCloseTime()) {
                  l_datetime_16 = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4 = NormalizeDouble(OrderLots() * MultiLotsFactor, gd_240);
                  else l_lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, l_lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (l_lots_4);
}

int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

void CloseThisSymbolAll() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (g_pos_380 = OrdersTotal() - 1; g_pos_380 >= 0; g_pos_380--) {
      OrderSelect(g_pos_380, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Ask + ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh() {
   if (CountTrades() == 0) gd_424 = AccountEquity();
   if (gd_424 < gd_432) gd_424 = gd_432;
   else gd_424 = AccountEquity();
   gd_432 = AccountEquity();
   return (gd_424);
}

double FindLastBuyPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double FindLastSellPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}