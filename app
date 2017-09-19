from flask import Flask
from flask import request,jsonify
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String

app = Flask(__name__)

# 创建实例，并连接test库
engine = create_engine("mysql+pymysql://root:Zhaoyun0218@localhost/gd_blog",
                                    encoding='utf-8', echo=True)
# echo=True 显示信息
Base = declarative_base()  # 生成orm基类

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

@app.route('/backend/login',methods=['GET','POST'])
def login():
    u = User.from_json(request.json)
    return jsonify(u.to_json())



if __name__ == '__main__':
    app.run()

