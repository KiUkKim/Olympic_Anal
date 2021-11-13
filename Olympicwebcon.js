/**
 * 카카오 webp api 사용
 * 
 * 
 *  *
 * 웹브라우저에서 아래 주소의 페이지를 열고 웹페이지에서 요청
 *    http://localhost:3000/
 *
 */

var http = require('http'),
    fs = require('fs');

// 정상 연결
function onRequest(request, response){
    if(request.method == 'GET' && request.url == '/')
    {
        response.writeHead(200, {"Content-Type":"text/html"});
        fs.createReadStream("./public/Olympicweb.html").pipe(response);
    }else{
        response.writeHead('200', {'Content-Type':'text/html;charset=utf8'});
        response.write('<h2>서버 연결 실패</h2>');
        response.end();
    }
}

// 404 error
function send404Msg(response){
    response.write(404, {"Content-Type":"text/plain"});
    response.write("create 404 error message");
    response.end();
}

http.createServer(onRequest).listen(3000);
console.log("Server create");


