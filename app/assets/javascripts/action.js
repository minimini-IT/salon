//function initMap() {
//  var test ={lat: 34.7019399, lng: 135.51002519999997};
//  var map = new google.maps.Map(document.getElementById('map'), {
//    zoom: 15,
//    center: test
//  });
//  var transitLayer = new google.maps.TransitLayer();
//  transitLayer.setMap(map);
//
//  var contentString = '住所：hoge';
//  var infowindow = new google.maps.InfoWindow({
//    content: contentString
//  });
//
//  var marker = new google.maps.Marker({
//    position:test,
//    map: map,
//    title: contentString
//  });
//
//  marker.addListener('click', function() {
//    infowindow.open(map, marker);
//  });
//<script async defer
//        src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyAClZyQNNSuhJtOIvDCbBSlrBwPci8BphM&callback=initMap">
//</script>
//}

$(function(){
  var month = $("#month").val();
  console.log(month);
  var day = $("#day").val();
  console.log(day);

  // 月が変更されたらvalue属性の値を取り出す
  $("#month").change(function(){
    var month = $("#month").val();
    console.log(month);
    getTimes()
  });

  // 日が変更されたらvalue属性の値を取り出す
  $("#day").change(function(){
    var day = $("#day").val();
    console.log(day);
    getTimes()
  });

  function getTimes(){
    $.ajax({
      url: "/reservations",
      type: "GET",
      data: { 
        month: $("#month").val(),
        day: $("#day").val()
      },
      success: function(data){
        console.log("success");
        console.log(data.time);
        var option = "";
        for (var i = 0; i < data.time.length; i++){
          option += '<option value="' + data.time[i] + '">' + data.time[i] + '</option>'
        }
        $(".select_time").html(option);
      },
      error: function(data){
        console.log("error");
      }
    });
  };


  
//  var test = $("#month").prop("month");
//  console.log(test);
//  var header = $("#header");  //スクロールするヘッダーのid
//  var adclass = "scrolled";   //スクロールバーのクラス
//  var scrollY = 15;           //スクロール幅(px)
//  $(window).scroll(function(){
//    if ($(window).scrollTop() > scrollY){
//      header.addClass(adclass);
//    }else{
//      header.removeClass(adclass);
//    }
//  });
//  var map;
//  function initMap(){
//    map = new google.maps.Map(document.getElementById("map"),{
//      center:{
//        lat: 34.7019399,     //緯度
//        leg: 135.51002519999997     //経度
//      },
//      zoom: 19 //地図のズーム
//    });
//  }
});


