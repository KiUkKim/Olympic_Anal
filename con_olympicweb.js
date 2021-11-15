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
	express = require('express'),
    fs = require('fs'),
	path = require('path');

// Express의 미들웨어 불러오기
var errorHandler = require('errorhandler'),
	static = require('serve-static'),
	bodyParser = require('body-parser'),
	cookieParser = require('cookie-parser');

// Session 미들웨어 불러오기
var expressSession = require('express-session');

// ErrorHandler 모듈 사용
var expressErrorHandler = require('express-error-handler');

// Express 객체 생성
var app = express();

// 기본 속성 설정
app.set('port', process.env.PORT || 3000);


// public 폴더를 static으로 오픈
app.use('/public', static(path.join(__dirname, 'public')));

// cookie-parser 설정
app.use(cookieParser());

// 세션 설정
app.use(expressSession({
	secret:'my key',
	resave:true,
	saveUninitialized:true
}));

// public 폴더를 static으로 오픈
app.use('/public', static(path.join(__dirname, 'public')));

// r script를 위함
var child_process = require('child_process');
var exec = child_process.exec;

//===== 라우팅 함수 등록 =====//

// 라우터 객체 참조
var router = express.Router();

router.route('/process/web').post(function(req,res){
	console.log('/process/web 호출됨.');

	var cmd = 'Rscript ./public/rscripts/ayl_wrapper.R ' + e2_in.toString() + " " + e2_out.toString();

	exec(cmd, (error, stdout, stderr) => {
        if(error) {
            console.error(error);
            return;
        }

        res.send("<h2>Log<sub>" + es_in.toString() + " " + es_out.toString() + "</h2>");
    } );
});


// 404 에러 페이지 처리
var errorHandler = expressErrorHandler({
	static: {
	'404': './public/404.html'
	}
});

app.use( expressErrorHandler.httpError(404) );
app.use( errorHandler );


//===== 서버 시작 =====//
// 프로세스 종료 시에 연결 해제
process.on('SIGTERM', function () {
    console.log("프로세스가 종료됩니다.");
    app.close();
});

app.on('close', function () {
	console.log("Express 서버 객체가 종료됩니다.");
});

// Express 서버 시작
http.createServer(app).listen(app.get('port'), function(){
	console.log('서버가 시작되었습니다. 포트 : ' + app.get('port'));

});