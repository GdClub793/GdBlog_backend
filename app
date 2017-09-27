from flask import Flask
from flask import request,jsonify
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker
from werkzeug.security import check_password_hash,generate_password_hash
from flask.ext.login import login_manager,login_user

app = Flask(__name__)

login_manager = login_manager()

# 创建实例，并连接test库
engine = create_engine("mysql+pymysql://root:275265zt@localhost/gd_blog",
                                    encoding='utf-8', echo=True)
# echo=True 显示信息
Base = declarative_base()  # 生成orm基类

session = sessionmaker(bind=engine)
session1 = session()

class User(Base):
    __tablename__ = 'user'  # 表名
    id = Column(Integer, primary_key=True)
    name = Column(String(32))
    password = Column(String(64))
    #资源转json
    def to_json(self):
        json_user={
            'id':self.id,
            'password': self.password,
            'name':self.name,
        }
        return json_user

        #json转资源

    @staticmethod
    def from_json(user):
        id = user.get('id')
        password = user.get('password')
        name = user.get('name')
        return User(id = id,password=password,name=name)



Base.metadata.create_all(engine) #创建表结构 （这里是父类调子类）

@app.route('/',methods=['GET','POST'])
def haha():
    return "haha"

@app.route('/backend/register',methods=['GET','POST'])
#增
def user_add():
    u = User.from_json(request.json)
    u.password = generate_password_hash(u.password)
    session1.add(u)
    session1.commit()
    return jsonify(u.to_json())
#查
@app.route('/home/query',methods=['GET','POST'])
def query():
    u = User.from_json(request.json)
    c = session1.query(User).filter_by(name = u.name).first()

    return jsonify(c.to_json())

#改
@app.route('/index/changename',methods=['GET','POST'])
def change():
    u = User.from_json(request.json)
    c = session1.query(User).filter_by(id = u.id).first()
    print(c.name,c.id,c.password)
    c.name = u.name
    session1.commit()
    return jsonify(c.to_json())
#删
@app.route('/index/delete',methods=['GET','POST'])
def delete():
    u = User.from_json(request.json)
    c = session1.query(User).filter_by(id = u.id).delete()
    session1.commit()
    return "done"

#登录
@app.route('/index/login',methods=['GET','POST'])
def login():
    u = User.from_json(request.json)
    c = session1.query(User).filter_by(name = u.name).first()
    if check_password_hash(c.password,u.password):
        login_user(u)
        return "gongxi"
    else:
        return "cuowu"

if __name__ == '__main__':
    app.run()
