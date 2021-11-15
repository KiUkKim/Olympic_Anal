/**
 * 카카오 webp api 사용
 * 
 * 
 *  *
 * 웹브라우저에서 아래 주소의 페이지를 열고 웹페이지에서 요청
 *    http://localhost:3000/olympiceweb.html
 *
 */

// express 기본 모듈
var http = require('http'),
    fs = require('fs');

// Express의 미들웨어 불러오기
var errorHandler = require('errorhandler');

// ErrorHandler 모듈 사용
var expressErrorHandler = requrie('expressErrorHandler');

// Express 객체 생성
var app = express();

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

//===== 라우팅 함수 등록 =====//

// 라우터 객체 참조
var router = express.Router();

router.route('/process/web').post(function(req,res){
	console.log('/process/web 호출됨.');
});


// 404 에러 페이지 처리
var errorHandler = expressErrorHandler({
	static: {
	'404': './public/404.html'
	}
});

app.use( expressErrorHandler.httpError(404) );
app.use( errorHandler );

// // 404 error
// function send404Msg(response){
//     response.write(404, {"Content-Type":"text/plain"});
//     response.write("create 404 error message");
//     response.end();
// }

http.createServer(onRequest).listen(3000);
console.log("Server create");


