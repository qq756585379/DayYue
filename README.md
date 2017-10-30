# DayYue

```
该方法将 selectedSide.url 传给app，app以key value形式存储在本地

if (bIsIphoneOs || bIsIpad) {
    getServerIP(selectedSide.url);
} else if (bIsAndroid) {
   $window.android.getAreaServerIP(selectedSide.url);
}
```



