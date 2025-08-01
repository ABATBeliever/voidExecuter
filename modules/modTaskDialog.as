#ifndef __modTaskDialog__
#define __modTaskDialog__
#module mtd
#uselib "comctl32"
#func TaskDialogIndirect "TaskDialogIndirect" var,var,int,int

#define global TDF_ENABLE_HYPERLINKS			0x0001
#define global TDF_USE_HICON_MAIN				0x0002
#define global TDF_USE_HICON_FOOTER				0x0004
#define global TDF_ALLOW_DIALOG_CANCELLATION	0x0008
#define global TDF_USE_COMMAND_LINKS			0x0010
#define global TDF_USE_COMMAND_LINKS_NO_ICON	0x0020
#define global TDF_EXPAND_FOOTER_AREA			0x0040
#define global TDF_EXPANDED_BY_DEFAULT			0x0080
#define global TDF_VERIFICATION_FLAG_CHECKED	0x0100
#define global TDF_SHOW_PROGRESS_BAR			0x0200
#define global TDF_SHOW_MARQUEE_PROGRESS_BAR	0x0400
#define global TDF_CALLBACK_TIMER				0x0800
#define global TDF_POSITION_RELATIVE_TO_WINDOW	0x1000
#define global TDF_RTL_LAYOUT					0x2000
#define global TDF_NO_DEFAULT_RADIO_BUTTON		0x4000
#define global TDF_CAN_BE_MINIMIZED				0x8000

#define global TD_WARNING_ICON         0x0000FFFF // MAKEINTRESOURCEW(-1)
#define global TD_ERROR_ICON           0x0000FFFE // MAKEINTRESOURCEW(-2)
#define global TD_INFORMATION_ICON     0x0000FFFD // MAKEINTRESOURCEW(-3)
#define global TD_SHIELD_ICON          0x0000FFFC // MAKEINTRESOURCEW(-4)

#define global TDCBF_OK_BUTTON 		0x01
#define global TDCBF_YES_BUTTON		0x02
#define global TDCBF_NO_BUTTON 		0x04
#define global TDCBF_CANCEL_BUTTON 	0x08
#define global TDCBF_RETRY_BUTTON 	0x10
#define global TDCBF_CLOSE_BUTTON 	0x20

#define global IDOK 		1
#define global IDCANCEL 	2
#define global IDABORT 		3
#define global IDRETRY 		4
#define global IDIGNORE 	5
#define global IDYES 		6
#define global IDNO 		7

#define global TDN_CREATED                         0
#define global TDN_NAVIGATED                       1
#define global TDN_BUTTON_CLICKED                  2
#define global TDN_HYPERLINK_CLICKED               3
#define global TDN_TIMER                           4
#define global TDN_DESTROYED                       5
#define global TDN_RADIO_BUTTON_CLICKED            6
#define global TDN_DIALOG_CONSTRUCTED              7
#define global TDN_VERIFICATION_CLICKED            8
#define global TDN_HELP                            9
#define global TDN_EXPANDO_BUTTON_CLICKED          10

#deffunc DialogVistaInit
// デフォルトパラメータ指定 (必要なら 変数名@mtd で書き換え可)
	select_start = 101		// 選択肢IDの開始番号

	// TaskDialogIndirect Function
	pnRadioButton = 0				// __out  int *pnRadioButton
	pfVerificationFlagChecked = 0 	//  __out  BOOL *pfVerificationFlagChecked

	// TASKDIALOGCONFIG Structure
	_hwnd = hwnd			// ウィンドウハンドル
	_hinstance = hinstance	// インスタンスハンドル
	dwFlags = TDF_ALLOW_DIALOG_CANCELLATION | TDF_USE_COMMAND_LINKS	| TDF_ENABLE_HYPERLINKS // 表示フラグ
	dwCommonButtons = 0
	nDefaultButton = 0
	cRadioButtons = 0
	pRadioButtons = 0
	nDefaultRadioButton = 0
	pszVerificationText = 0
	pszExpandedInformation = 0
	pszExpandedControlText = 0
	pszCollapsedControlText = 0
	pfCallback = 0
	lpCallbackData = 0
	cxWidth = 0				// ダイアログの幅（０で自動）
	
// デフォルトパラメータ定義終了
return

#deffunc DialogVistaEx str _title, str _main, str _content, str _footer, str _select, int _mainico, int _footico 

	// この関数が使えるかチェック
	if varptr(TaskDialogIndirect) = 0 : return -1	// 未サポート

	// タイトル文字列をユニコードに変換しポインターを取得
	if strlen(_title) > 0{
		sdim WTitle, strlen(_title)*2+2
		cnvstow WTitle, _title
		pWTitle = varptr(WTitle)
	}else{
		pWTitle = 0
	}
	
	// メインメッセージをユニコードに変換しポインターを取得
	if strlen(_main) > 0{
		sdim MMes, strlen(_main)*2+2
		cnvstow MMes, _main
		pMMes = varptr(MMes)
	}else{
		pMMes = 0
	}
	
	// 説明をユニコードに変換しポインターを取得
	if strlen(_content) > 0{
		sdim SMes, strlen(_content)*2+2
		cnvstow SMes, _content
		pSMes = varptr(SMes)
	}else{
		pSMes = 0
	}
	
	// フッターメッセージをユニコードに変換しポインターを取得
	if strlen(_footer) > 0{
		sdim FMes, strlen(_footer)*2+2
		cnvstow FMes, _footer
		pFMes = varptr(FMes)
	}else{
		pFMes = 0
	}

	// 選択肢を分解
	select = _select
	notesel select

	if notemax = 0 : return -2	// 選択肢が見つからない。もしくは正しくない。

	// 最大文字列長を取得
	maxsize = 0
	repeat notemax
		noteget tmp, cnt
		if strlen(tmp) > maxsize : maxsize = strlen(tmp)
	loop
	if maxsize = 0 : return -3	// サイズ不正

	// 最大文字列長で配列を初期化(少し大きめに初期化)
	sdim sel, maxsize*2+2, notemax

	// 配列に ユニコードに変換しながら格納
	repeat notemax
		noteget tmp, cnt
		cnvstow sel(cnt), tmp
	loop

	// TASKDIALOG_BUTTON 構造体の準備
	// http://msdn.microsoft.com/ja-jp/library/bb787475(en-us,VS.85).aspx
	dim dbtn, notemax*2
	st = select_start	// 選択肢ID初期値
	
	repeat notemax
		dbtn.(cnt*2) = st
		dbtn.(cnt*2+1) = varptr(sel(cnt))
		st++
	loop

	// メインアイコンIDの変換
	switch _mainico
		case 0 : mainico = 0 : swbreak
		case 1 : mainico = TD_WARNING_ICON : swbreak
		case 2 : mainico = TD_ERROR_ICON : swbreak
		case 3 : mainico = TD_INFORMATION_ICON : swbreak
		case 4 : mainico = TD_SHIELD_ICON : swbreak
		default : mainico = _mainico : swbreak
	swend

	// フッターアイコンIDの変換
	switch _footico
		case 0 : footico = 0 : swbreak
		case 1 : footico = TD_WARNING_ICON : swbreak
		case 2 : footico = TD_ERROR_ICON : swbreak
		case 3 : footico = TD_INFORMATION_ICON : swbreak
		case 4 : footico = TD_SHIELD_ICON : swbreak
		default : footico = _footico : swbreak
	swend

	// TASKDIALOGCONFIG 構造体の準備
	// http://msdn.microsoft.com/ja-jp/library/bb787473(en-us,VS.85).aspx
	
	dim taskconf,24

	taskconf.0 = 96	// cbSize 構造体のサイズ（96byte固定）
	taskconf.1 = _hwnd // hwndParent ウィンドウハンドル
	taskconf.2 = _hinstance // hInstance インスタンスハンドル
	taskconf.3 = dwFlags	// dwFlags 表示フラグ
	taskconf.4 = dwCommonButtons // dwCommonButtons (使うならTDCBF_OK_BUTTON系の定数を指定。使わないなら0。)
	taskconf.5 = pWTitle // pszWindowTitle　ダイアログのタイトル
	taskconf.6 = mainico // hMainIcon or pszMainIcon(共用体) メインに表示するアイコンIDもしくはハンドル
	taskconf.7 = pMMes // pszMainInstruction ダイアログのメインメッセージ
	taskconf.8 = pSMes // pszContent ダイアログサブメッセージ（説明）
	taskconf.9 = notemax // cButtons 用意したボタンの数
	taskconf.10 = varptr(dbtn) // *pButtons TASKDIALOG_BUTTON 構造体 のポインタ
	taskconf.11 = nDefaultButton // nDefaultButton (使うならIDOK系の定数を指定。使わないなら0。)
	taskconf.12 = cRadioButtons // cRadioButtons (ボタンではなくラジオボタン版？使わないなら0。)
	taskconf.13 = pRadioButtons // *pRadioButtons (ボタンではなくラジオボタン版？使わないなら0。)
	taskconf.14 = nDefaultRadioButton // nDefaultRadioButton 	(使うならIDOK系の定数を指定。使わないなら0。)
	taskconf.15 = pszVerificationText // pszVerificationText 
	taskconf.16 = pszExpandedInformation // pszExpandedInformation
	taskconf.17 = pszExpandedControlText // pszExpandedControlText
	taskconf.18 = pszCollapsedControlText // pszCollapsedControlText
	taskconf.19 = footico // hFooterIcon or pszFooterIcon(共用体) フッターに表示するアイコンIDもしくはハンドル
	taskconf.20 = pFMes // pszFooter ダイアログのフッターのメッセージ
	taskconf.21 = pfCallback // pfCallback コールバック関数系(使わないので0)
	taskconf.22 = lpCallbackData // lpCallbackData コールバック関数系(使わないので0)
	taskconf.23 = cxWidth // cxWidth ダイアログの幅？
	
	// 実行
	choose = 0
	TaskDialogIndirect taskconf, choose, pnRadioButton, pfVerificationFlagChecked
	if stat != 0 : return stat	// エラーをそのままつき返す

	return choose	// 選択したIDを返す
#global
#endif
	DialogVistaInit // 初期化