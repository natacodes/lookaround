addrToUrl = (address) ->
  
  #Установить #значение:
  addressFormatted = address.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/-$/, "")
  window.location.href = window.location.href.replace(/#.*/g, "") + "#addr-" + addressFormatted

#Получить это значение из адресной строки:
#window.location.href.match(/#.*/)[0];
tagToUrl = (tag) ->
  window.location.href = window.location.href.replace(/#.*/g, "") + "#tag-" + tag
  window.location.href = window.location.href.replace(/#.*/g, "") + "#tag-" + tag