package core

main :: proc()
{
  wc   : win.WNDCLASSEXA
  hwnd : win.HWND
  msg  : win.MSG

  //step 1: registering the window class
  wc.cbSize        = size_of(win.WNDCLASSEXA);
  wc.style         = 0;
  wc.lpfnWndProc   = win32_window_callback
  wc.cbClsExtra    = 0;
  wc.cbWndExtra    = 0;
  wc.hInstance     = hInstance;
  wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
  wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
  wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
  wc.lpszMenuName  = NULL;
  wc.lpszClassName = g_szClassName;
  wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);

  if(!RegisterClassEx(&wc))
  {
      MessageBox(NULL, "Window Registration Failed!", "Error!",
          MB_ICONEXCLAMATION | MB_OK);
      return 0;
  }

  // Step 2: Creating the Window
  hwnd = CreateWindowEx(
      WS_EX_CLIENTEDGE,
      g_szClassName,
      "The title of my window",
      WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, CW_USEDEFAULT, 240, 120,
      NULL, NULL, hInstance, NULL);

  if(hwnd == NULL)
  {
      MessageBox(NULL, "Window Creation Failed!", "Error!",
          MB_ICONEXCLAMATION | MB_OK);
      return 0;
  }

  ShowWindow(hwnd, nCmdShow);
  UpdateWindow(hwnd);

  // Step 3: The Message Loop
  while(GetMessage(&Msg, NULL, 0, 0) > 0)
  {
      TranslateMessage(&Msg);
      DispatchMessage(&Msg);
  }
  return Msg.wParam;
}
