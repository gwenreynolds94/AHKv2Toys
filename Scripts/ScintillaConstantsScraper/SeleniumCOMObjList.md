
# Selenium.IEDriver

Methods
----

    ActiveElement                     () 
                                        -> Selenium.WebElement

    AddArgument                      (string argument) 
                                        -> void

    AddExtension                     (string extensionPath) 
                                        -> void

    CacheStatus                       () 
                                        -> Selenium.CacheState

    Close                             () 
                                        -> void

    Dispose                           () 
                                        -> void

    Equals                           (System.Object obj) 
                                        -> bool

    ExecuteAsyncScript               (string script, System.Object arguments, int timeout) 
                                        -> System.Object

    ExecuteScript                    (string script, System.Object arguments) 
                                        -> System.Object

    FindElement                      (Selenium.By by, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementBy                    (Selenium.Strategy strategy, string value, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByClass               (string classname, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByCss                 (string cssselector, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementById                  (string id, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByLinkText            (string linktext, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByName                (string name, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByPartialLinkText     (string partiallinktext, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByTag                 (string tagname, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByXPath               (string xpath, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElements                     (Selenium.By by, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsBy                   (Selenium.Strategy strategy, string value, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByClass              (string classname, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByCss                (string cssselector, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsById                 (string id, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByLinkText           (string linktext, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByName               (string name, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByPartialLinkText    (string partiallinktext, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByTag                (string tagname, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByXPath              (string xpath, int minimum, int timeout) 
                                        -> Selenium.WebElements

    Get                              (string url, int timeout, bool raise) 
                                        -> bool

    GetClipBoard                      () 
                                        -> string

    GetHashCode                       () 
                                        -> int

    GetType                           () 
                                        -> type

    GoBack                            () 
                                        -> void

    GoForward                         () 
                                        -> void

    IsElementPresent                 (Selenium.By by, int timeout) 
                                        -> bool

    PageSource                        () 
                                        -> string

    PageSourceMatch                  (string pattern, int16 group) 
                                        -> string

    PageSourceMatches                (string pattern, int16 group) 
                                        -> Selenium.List

    Quit                              () 
                                        -> void

    Refresh                           () 
                                        -> void

    Send                             (string method, string relativeUri, 
                                            string param1, System.Object value1, 
                                            string param2, System.Object value2, 
                                            string param3, System.Object value3, 
                                            string param4, System.Object value4) 
                                        -> System.Object

    SendKeys                         (string keysOrModifier, string keys) 
                                        -> void

    SetBinary                        (string path) 
                                        -> void

    SetCapability                    (string key, System.Object value) 
                                        -> void

    SetClipBoard                     (string text) 
                                        -> void

    SetPreference                    (string key, System.Object value) 
                                        -> void

    SetProfile                       (string nameOrDirectory, bool persistant) 
                                        -> void

    Start                            (string browser, string baseUrl) 
                                        -> void

    StartRemotely                    (string executorUri, string browser, string version, string platform) 
                                        -> void

    SwitchToAlert                    (int timeout, bool raise) 
                                        -> Selenium.Alert

    SwitchToDefaultContent            () 
                                        -> void

    SwitchToFrame                    (System.Object identifier, int timeout, bool raise) 
                                        -> bool

    SwitchToNextWindow               (int timeout, bool raise) 
                                        -> Selenium.Window

    SwitchToParentFrame               () 
                                        -> void

    SwitchToPreviousWindow            () 
                                        -> Selenium.Window

    SwitchToWindowByName             (string name, int timeout, bool raise) 
                                        -> Selenium.Window

    SwitchToWindowByTitle            (string title, int timeout, bool raise) 
                                        -> Selenium.Window

    TakeScreenshot                   (int delay) 
                                        -> Selenium.Image

    ToString                          () 
                                        -> string

    Until                            [T](System.Func[Selenium.WebDriver,T] func, int timeout) 
                                        -> T

    Wait                             (int timems) 
                                        -> void

    WaitForScript                    (string script, System.Object arguments, int timeout) 
                                        -> System.Object

    WaitNotElement                   (Selenium.By by, int timeout) 
                                        -> void


Properties
----

    Actions                         Selenium.Actions Actions {get;}

    BaseUrl                         string BaseUrl {get;set;}

    Keyboard                        Selenium.Keyboard Keyboard {get;}

    Keys                            Selenium.Keys Keys {get;}

    Manage                          Selenium.Manage Manage {get;}

    Mouse                           Selenium.Mouse Mouse {get;}

    Proxy                           Selenium.Proxy Proxy {get;}

    Timeouts                        Selenium.Timeouts Timeouts {get;}

    Title                           string Title {get;}

    TouchActions                    Selenium.TouchActions TouchActions {get;}

    TouchScreen                     Selenium.TouchScreen TouchScreen {get;}

    Url                             string Url {get;}

    Window                          Selenium.Window Window {get;}

    Windows                         Selenium.List Windows {get;}


#
#
#
#
#
# Selenium.WebElement

Methods
----

    AsSelect                        () 
                                        -> Selenium.SelectElement

    AsTable                         () 
                                        -> Selenium.TableElement

    Attribute                      (string attribute) 
                                        -> System.Object

    Clear                           () 
                                        -> Selenium.WebElement

    Click                          (string keys) 
                                        -> void

    ClickAndHold                    () 
                                        -> void

    ClickByOffset                  (int offset_x, int offset_y) 
                                        -> void

    ClickContext                    () 
                                        -> void

    ClickDouble                     () 
                                        -> void

    CssValue                       (string property) 
                                        -> System.Object

    DragAndDropToOffset            (int offsetX, int offsetY) 
                                        -> void

    DragAndDropToWebElement        (Selenium.WebElement element) 
                                        -> void

    Equals                         (Selenium.WebElement other), bool _WebElement.Equals(System.Object obj) 
                                        -> bool

    ExecuteAsyncScript             (string script, System.Object arguments, int timeout) 
                                        -> System.Object

    ExecuteScript                  (string script, System.Object arguments) 
                                        -> System.Object

    FindElement                    (Selenium.By by, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementBy                  (Selenium.Strategy strategy, string value, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByClass             (string classname, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByCss               (string cssselector, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementById                (string id, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByLinkText          (string linktext, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByName              (string name, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByPartialLinkText   (string partiallinktext, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByTag               (string tagname, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElementByXPath             (string xpath, int timeout, bool raise) 
                                        -> Selenium.WebElement

    FindElements                   (Selenium.By by, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsBy                 (Selenium.Strategy strategy, string value, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByClass            (string classname, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByCss              (string cssselector, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsById               (string id, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByLinkText         (string linktext, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByName             (string name, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByPartialLinkText  (string partiallinktext, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByTag              (string tagname, int minimum, int timeout) 
                                        -> Selenium.WebElements

    FindElementsByXPath            (string xpath, int minimum, int timeout) 
                                        -> Selenium.WebElements

    GetHashCode                     () 
                                        -> int

    GetType                         () 
                                        -> type

    HoldKeys                       (string modifiers) 
                                        -> void

    IsElementPresent               (Selenium.By by, int timeout) 
                                        -> bool

    Location                        () 
                                        -> Selenium.Point

    LocationInView                  () 
                                        -> Selenium.Point

    ReleaseKeys                    (string modifiers) 
                                        -> void

    ReleaseMouse                    () 
                                        -> void

    ScrollIntoView                 (bool alignTop) 
                                        -> Selenium.WebElement

    SendKeys                       (string keysOrModifier, string keys) 
                                        -> Selenium.WebElement

    SerializeJson                   () 
                                        -> Selenium.Dictionary

    Size                            () 
                                        -> Selenium.Size

    Submit                          () 
                                        -> void

    TakeScreenshot                 (int delayms) 
                                        -> Selenium.Image

    Text                            () 
                                        -> string

    TextAsNumber                   (string decimalCharacter, System.Object errorValue) 
                                        -> System.Object

    TextMatch                      (string pattern) 
                                        -> string

    TextMatches                    (string pattern) 
                                        -> Selenium.List

    ToString                        () 
                                        -> string

    Until                          [T](System.Func[Selenium.WebElement,T] func, int timeout) 
                                        -> T

    Value                           () 
                                        -> System.Object

    WaitAttribute                  (string attribute, string pattern, int timeout) 
                                        -> Selenium.WebElement

    WaitCssValue                   (string propertyName, string value, int timeout) 
                                        -> Selenium.WebElement

    WaitDisplayed                  (bool displayed, int timeout) 
                                        -> Selenium.WebElement

    WaitEnabled                    (bool enabled, int timeout) 
                                        -> Selenium.WebElement

    WaitForScript                  (string script, System.Object arguments, int timeout) 
                                        -> System.Object

    WaitNotAttribute               (string attribute, string pattern, int timeout) 
                                        -> Selenium.WebElement

    WaitNotCssValue                (string propertyName, string value, int timeout) 
                                        -> Selenium.WebElement

    WaitNotElement                 (Selenium.By by, int timeout) 
                                        -> void

    WaitNotText                    (string pattern, int timeout) 
                                        -> Selenium.WebElement

    WaitRemoval                    (int timeout) 
                                        -> void

    WaitSelection                  (bool selected, int timeout) 
                                        -> Selenium.WebElement

    WaitText                       (string pattern, int timeout) 
                                        -> Selenium.WebElement



Properties
----

    IsDisplayed         bool IsDisplayed {get;}
    IsEnabled           bool IsEnabled {get;}
    IsPresent           bool IsPresent {get;}
    IsSelected          bool IsSelected {get;}
    Rect                System.Object Rect {get;}
    TagName             string TagName {get;}