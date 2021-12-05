from flask import Flask, render_template, request, json, redirect,session
from flaskext.mysql import MySQL
app = Flask(__name__)
app.debug = True

mysql = MySQL()
app.secret_key = 'secreto'
#MySQL Configuracion
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'holamundo'
app.config['MYSQL_DATABASE_DB'] = 'tienda_natacion'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

@app.route("/")
def main():
    return render_template('index.html')

@app.route('/showSignUp')
def showSignUp():
    return render_template('signup.html')

@app.route('/signUp', methods = ['POST','GET'])
def signUp():
    _dni = request.form['inputDNI']
    _nombre = request.form['inputNombre']
    _p_apellido = request.form['inputP_Apellido']
    _s_apellido = request.form['inputS_Apellido']
    _direccion = request.form['inputDireccion']
    _telefono = request.form['inputTelefono']
    _email = request.form['inputEmail']
    _password = request.form['inputPassword']
    _sies = request.form['inputSies']
    if _dni and _nombre and _p_apellido and _s_apellido and _direccion and _telefono and _email and _password and _sies:
        conn = mysql.connect()
        if (conn):
            print("Conexion establecida")
        else:
            print("Conexion fallida")
        cursor = conn.cursor()
        cursor.callproc('crearPersona',(_dni, _nombre, _p_apellido, _s_apellido, _direccion, _telefono, _email, _password,_sies))
        data = cursor.fetchall()
        if len(data) ==0:
            conn.commit()
            print("Usuario fue creado!")
            return json.dumps({'mensaje':'usuario fue creado!'})
        else:
            print({'error':str(data[0])})
    else:
        return json.dumps({'mensaje': 'Campos estan vacios!'})
    cursor.close()
    conn.close()



@app.route('/showSignin')
def showSignin():
    if session.get('user'):#Si la sesion del usuario sigue activa ingresamos
        return render_template('userHome.html')
    else:
        return render_template('signin.html')#Ingresamois con nuestro usuario

@app.route('/userHome')
def userHome():
    if session.get('user'):
        return render_template('userHome.html')
    else:
        return render_template('error.html',error = 'Acceso No Autorizado')

@app.route('/vendedorHome')
def vendedorHome():
    if session.get('user'):
        return render_template('vendedorHome.html')
    else:
        return render_template('error.html',error = 'Acceso No Autorizado')

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')

@app.route('/validateLogin', methods = ['POST'])
def validateLogin():
    _username = request.form['inputEmail']
    _password = request.form['inputPassword']
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.callproc('validarLogin',(_username,))#Llamamos al procedimiento validarLogin de nuestra base de datos
    data = cursor.fetchall()#Obtenemos el resultado  en este caso una tabla
    if len(data)>0:#Si la tabla no esta vacia
        if str(data[0][7]) == _password:
            session['user'] = data[0][0]#asignamos dni
            if data[0][8]:
               return redirect('/userHome')
            else: 
                return redirect('/vendedorHome')
        else:
            return render_template('error.html', error='Usuario o contraseña es incorrecta')
    else:
        return render_template('error.html', error = 'Usuario no existe')
    cursor.close()
    conn.close()




@app.route('/showAddWish')
def showAddWish():
    return render_template('addWish.html')

@app.route('/showProduct')
def showProduct():
    return render_template('addProduct.html')

@app.route('/addProduct', methods=['POST'])
def addProduct():
    if session.get('user'):
        _idlente = request.form['inputIdlente1']
        _title = request.form['inputTitle1']#marca
        _descripcion = request.form['inputDescription1']#descripcion
        _user = session.get('user')
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.callproc('agregarProducto', (_idlente,_title, _descripcion, _user,))
        data = cursor.fetchall()
        if len(data) == 0:
            conn.commit()
            return redirect('userHome')
        else:
            return render_template('error.html', error='Un error detectado')

    else:
        return render_template('error.html', error='Acceso no Autorizado')
    cursor.close
    conn.close

@app.route('/addWish', methods=['POST'])
def addWish():
    if session.get('user'):
        _idlente = request.form['inputIdlente']
        _title = request.form['inputTitle']#marca
        _descripcion = request.form['inputDescription']#descripcion
        _user = session.get('user')
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.callproc('agregarCompra', (_idlente,_title, _descripcion, _user,))
        data = cursor.fetchall()
        if len(data) == 0:
            conn.commit()
            return redirect('userHome')
        else:
            return render_template('error.html', error='Un error detectado')

    else:
        return render_template('error.html', error='Acceso no Autorizado')
    cursor.close
    conn.close



@app.route('/getWish')
def getWish():
    if session.get('user'):
        _user = session.get('user')

        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.callproc('obtenerCompra', (_user,))
        data = cursor.fetchall()
        deseos_list = []
        for deseo in data:
            deseo_list = {
                'Id': deseo[0],
                'Marca': deseo[1],#marca
                'Description': deseo[2],
                'Precio': deseo[3],
                'Cantidad':deseo[4]}#precio
            deseos_list.append(deseo_list)
        return json.dumps(deseos_list)
    else:
        return render_template('error.html', error='Acceso no Autorizado')
    cursor.close
    conn.close
@app.route('/getProduct')
def getProduct():
    if session.get('user'):
        #_user = session.get('user')

        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.callproc('obtenerProducto')
        data = cursor.fetchall()
        deseos_list = []
        for deseo in data:
            deseo_list = {
                'Id': deseo[0],
                'Marca': deseo[3],#marca
                'Description': deseo[1],
                'Precio': deseo[2],
                'Stock':deseo[4]}#cantidad
            deseos_list.append(deseo_list)
        return json.dumps(deseos_list)
    else:
        return render_template('error.html', error='Acceso no Autorizado')
    cursor.close
    conn.close

if __name__ == "__main__":
    app.run()