/**
 * 데이터베이스 사용하기
 * 
 * mongoose로 데이터베이스 다루기
 *
 * 웹브라우저에서 아래 주소의 페이지를 열고 웹페이지에서 요청
 *    http://localhost:3000/public/memo.html
 *
 */

// Express 기본 모듈 불러오기
var express = require('express')
  , http = require('http')
  , path = require('path');

// Express의 미들웨어 불러오기
var bodyParser = require('body-parser')
  , cookieParser = require('cookie-parser')
  , static = require('serve-static')
  , errorHandler = require('errorhandler');

// 에러 핸들러 모듈 사용
var expressErrorHandler = require('express-error-handler');

// Session 미들웨어 불러오기
var expressSession = require('express-session');
 
// mongoose 모듈 사용
var mongoose = require('mongoose');


// 익스프레스 객체 생성
var app = express();

var crypto = require('crypto');

// 기본 속성 설정
app.set('port', process.env.PORT || 3000);

// body-parser를 이용해 application/x-www-form-urlencoded 파싱
app.use(bodyParser.urlencoded({ extended: false }))

// body-parser를 이용해 application/json 파싱
app.use(bodyParser.json())

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



//===== 데이터베이스 연결 =====//

// 데이터베이스 객체를 위한 변수 선언
var database;

// 데이터베이스 스키마 객체를 위한 변수 선언
var UserSchema;

// 데이터베이스 모델 객체를 위한 변수 선언
var UserModel;

//데이터베이스에 연결
function connectDB() {
	// 데이터베이스 연결 정보
	var databaseUrl = 'mongodb://localhost:27017/local';
	 
	// 데이터베이스 연결
    console.log('데이터베이스 연결을 시도합니다.');
    mongoose.Promise = global.Promise;  // mongoose의 Promise 객체는 global의 Promise 객체 사용하도록 함
	mongoose.connect(databaseUrl);
	database = mongoose.connection;
	
	database.on('error', console.error.bind(console, 'mongoose connection error.'));	
	database.on('open', function() {
		console.log('데이터베이스에 연결되었습니다. : ' + databaseUrl);
		// user 스키마 및 모델 객체 생성
		createUserSchema();
		// test 진행함
		//doTest();
	});	
		
    // 연결 끊어졌을 때 5초 후 재연결
	database.on('disconnected', function() {
        console.log('연결이 끊어졌습니다. 5초 후 재연결합니다.');
        setInterval(connectDB, 5000);
    });
}

function createUserSchema()
{
	
		// 스키마 정의
	UserSchema = mongoose.Schema({
		author : {type : String, required : [true, '작성자 이름이 필요합니다.'], unique: false},
		contents : {type : String, required : [true, '내용이 필요합니다.'], unique: false},
		createDate : {type : Date, index : {unique : false}, 'default' : Date.now}
	});
			

	// 필수 속성에 대한 유효성 확인 (길이 값 체크)
	UserSchema.path('author').validate(function(author) {
		return author.length;
	}, 'author 칼럼의 값이 없습니다.');
	
	UserSchema.path('contents').validate(function(contents) {
		return contents.length;
	}, 'contents 칼럼의 값이 없습니다.');

	console.log('UserSchema 정의함.');

	// UserModel 모델 정의
	UserModel = mongoose.model("memoinfo", UserSchema);
	console.log("UserModel 정의함.");
}

//===== 라우팅 함수 등록 =====//

// 라우터 객체 참조
var router = express.Router();

// 메모 정보 추가 라우팅 함수 - 클라이언트에서 보내오는 데이터를 이용해 데이터베이스에 추가
router.route('/process/save').post(function(req, res) {
	console.log('/process/adduser 호출됨.');

    var paramAuthor = req.body.author || req.query.author;
    var paramContents = req.body.contents || req.query.contents;
	var paramDate = req.body.createDate || req.query.createDate;
	
    console.log('요청 파라미터 : ' + paramAuthor + ', ' + paramContents + ', ' + paramDate);
    
    // 데이터베이스 객체가 초기화된 경우, addUser 함수 호출하여 사용자 추가
	if (database) {
		addMemoInfo(database, paramAuthor, paramContents, paramDate, function(err, addedMemo) {
			if (err) {throw err;}
			
            // 결과 객체 있으면 성공 응답 전송
			if (addedMemo) {
				console.dir(addedMemo);

				res.writeHead('200', {'Content-Type':'text/html;charset=utf8'});
				res.write('<h3>나의 메모</h3><br>');
                res.write('<h2>&nbsp&nbsp메모가 저장 되었습니다.</h2>');
                res.write('<br><br><button onclick = "history.back()">다시 작성</button>');
				res.end();
			} else {  // 결과 객체가 없으면 실패 응답 전송
				res.writeHead('200', {'Content-Type':'text/html;charset=utf8'});
                res.write('<h3>나의 메모</h3><br>');
				res.write('<h2>&nbsp&nbsp메모 저장 실패</h2>');
				res.write('<br><br><button onclick = "history.back()">다시 작성</button>');
				res.end();
			}
		});
	} else {  // 데이터베이스 객체가 초기화되지 않은 경우 실패 응답 전송
		res.writeHead('200', {'Content-Type':'text/html;charset=utf8'});
		res.write('<h2>데이터베이스 연결 실패</h2>');
		res.end();
	}
	
});

// 라우터 객체 등록
app.use('/', router);

// 메모내용 추가하는 함수
var addMemoInfo = function(database, author , contents, createDate, callback) {
	console.log('addMemoInfo 호출됨 : ' + author + ', ' + contents + ', ' + createDate);
	
	// UserModel 인스턴스 생성
	var memo = new UserModel({"author":author, "contents":contents, "createDate":createDate});

	// save()로 저장 : 저장 성공 시 addedMemo 객체가 파라미터로 전달됨
	// ppt처럼 저장해도 된다.
	memo.save(function(err) {
		if (err) {
			callback(err, null);
			return;
		}
		
		console.log("메모 데이터 추가함.");
		callback(null, memo);

	});
};


// 404 에러 페이지 처리
var errorHandler = expressErrorHandler({
 static: {
   '404': './public/404.html'
 }
});

app.use( expressErrorHandler.httpError(404) );
app.use( errorHandler );


//===== 서버 시작 =====//

// 프로세스 종료 시에 데이터베이스 연결 해제
process.on('SIGTERM', function () {
    console.log("프로세스가 종료됩니다.");
    app.close();
});

app.on('close', function () {
	console.log("Express 서버 객체가 종료됩니다.");
	if (database) {
		database.close();
	}
});

// Express 서버 시작
http.createServer(app).listen(app.get('port'), function(){
  console.log('서버가 시작되었습니다. 포트 : ' + app.get('port'));

  // 데이터베이스 연결을 위한 함수 호출
  connectDB();

});