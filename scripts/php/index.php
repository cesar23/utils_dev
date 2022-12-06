<?php
session_start();
define("VERSION",'1.0.1');
if (!isset($_SESSION['command'])) {
    $_SESSION['command'] = array();
}


$command = "";


function getIpLocal()
{
    exec("hostname -I | awk '{print $1}'", $output, $return_var);
    return $output[0];
}


function getStartStress()
{

    $result_json = array('statusCode' => 200, 'msg' => "");
    try {
        $command = 'stress-ng --cpu 4 -v --timeout 60s > /dev/null 2 >/dev/null &';
        exec($command);
        if (!isset($_SESSION['command'])) {
            array_push($_SESSION['command'], date("Y-m-d H:i:s") . "[separador]" . $command);
        } else {
            array_push($_SESSION['command'], date("Y-m-d H:i:s") . "[separador]" . $command);
        }
        $result_json["statusCode"] = 200;
        $result_json["msg"] = $_SESSION['command'];
    } catch (Exception $e) {
        $result_json["statusCode"] = 500;
        $result_json["msg"] = $e->getMessage();
//        echo 'Caught exception: ',  $e->getMessage(), "\n";
    }
    echo json_encode($result_json);
    exit;
}

function getStopStress()
{

    $result_json = array('statusCode' => 200, 'msg' => "");
    try {
        $command = 'pkill -9 stress-ng-cpu';
        exec($command);
        if (!isset($_SESSION['command'])) {
            array_push($_SESSION['command'], date("Y-m-d H:i:s") . "[separador]" . $command);
        } else {
            array_push($_SESSION['command'], date("Y-m-d H:i:s") . "[separador]" . $command);
        }
        $result_json["statusCode"] = 200;
        $result_json["msg"] = $_SESSION['command'];
    } catch (Exception $e) {
        $result_json["statusCode"] = 500;
        $result_json["msg"] = $e->getMessage();
//        echo 'Caught exception: ',  $e->getMessage(), "\n";
    }
    echo json_encode($result_json);
    exit;

}

function getInfoPC()
{
    // CPU usado
    exec("top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'|awk '{print \"CPU Usage: \" 100-$8 \"%\"}' ", $output_cpu, $return_var);
    // info de memoria
    exec("free -h | grep Mem | awk '{print \"Memoria  total: \" $2 \" , usada:\"$3 \" , free: \"$4 }' ", $output_mem, $return_var);
    // porcentaje de  memeoia  usada
    exec("free | grep Mem | awk '{print \"Procentaje Memoria Usada: %\" $3/$2 * 100.0}'", $output_mem_porcentaje, $return_var);
    $info_cpu = $output_cpu[0];
    $info_memoria = $output_mem[0];
    $info_memoria_porcentaje = $output_mem_porcentaje[0];


// send the result now
    $result_json = array('info_cpu' => $info_cpu, 'info_memoria' => $info_memoria, "info_memoria_porcentaje" => $info_memoria_porcentaje);
    echo json_encode($result_json);
    exit;
}

function getHistoryCommads()
{
    $result_json = array('statusCode' => 200, 'msg' => "");
    if (!isset($_SESSION['command'])) {
        $result_json["statusCode"] = 200;
        $result_json["msg"] = [];
    } else {
        $result_json["statusCode"] = 200;
        $result_json["msg"] = $_SESSION['command'];
    }

    echo json_encode($result_json);
    exit;
}
function getHistoryClearCommads()
{
    $result_json = array('statusCode' => 200, 'msg' => "");
    if (!isset($_SESSION['command'])) {
        $result_json["statusCode"] = 200;
        $result_json["msg"] = [];
    } else {
        $result_json["statusCode"] = 200;
        $_SESSION['command']=[];
        $result_json["msg"] = $_SESSION['command'];
    }

    echo json_encode($result_json);
    exit;
}

function shell_ejecute($cmd)
{
    exec(" ${cmd} ", $output, $return_var);
    $result_json = array('statusCode' => 200, 'msg' => "",'return'=>'');
    if ($return_var>0) {
        $result_json["statusCode"] = 200;
        $result_json["msg"] = $output;
        $result_json["return"] = $return_var;
    } else {
        $result_json["statusCode"] = 200;
        $_SESSION['command']=[];
        $result_json["msg"] = $output;
        $result_json["return"] = $return_var;
    }

    echo json_encode($result_json);
    exit;
}


if (strlen(isset($_GET['get_data'])) > 0) {
    // -----respuesta  json
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    header('Content-type: application/json');

    switch ($_GET['get_data']) {
        case "info_server":
            getInfoPC();
            break;
        case "start_stress":
            getStartStress();
            break;
        case "stop_stress":
            getStopStress();
            break;
        case "get_history_command":
            getHistoryCommads();
            break;

        case "get_history_clear_command":
            getHistoryClearCommads();
            break;
    }

}


$_POST = json_decode(file_get_contents("php://input"),true);



if (strlen(isset($_POST)) > 0) {
    // -----respuesta  json
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    header('Content-type: application/json');

   shell_ejecute($_POST['cmd']);


}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel de stress Server</title>
    <link rel="icon" type="image/x-icon" href="https://getbootstrap.com/docs/5.2/assets/img/favicons/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">

    <style>
        .loading {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            transition: 1s all;
            opacity: 0;
        }
        .loading.show {
            opacity: 1;
        }
        .loading .spin {
            border: 3px solid hsla(185, 100%, 62%, 0.2);
            border-top-color: #3cefff;
            border-radius: 50%;
            width: 3em;
            height: 3em;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
    </style>
</head>

<body>
<!-- Loading -->
<div class="loading show" id="loader_web">
    <div class="spin"></div>
</div>

<div class="container text-center">
    <div class="row" style="padding: 7px">
        <div class="col">
                Version <?php echo VERSION;?>
        </div>
        <div class="col">
            <img src="https://pbs.twimg.com/profile_images/1377340526890872832/Qvi0U8pF_400x400.jpg" width="100px"
                 alt="">
        </div>
        <div class="col">

        </div>
    </div>



    <div class="row" style="padding: 7px">
        <div class="col-4">
        </div>
        <div class="col-4">
            <h3 class="card-title">1. IP Server Local</h3>
            <div style="background-color: #0052bb; color:#fff; border-radius: 15px; overflow-y: scroll; height:60px;">
                <strong><?php echo getIpLocal(); ?></strong>
            </div>

        </div>
        <div class="col-4">
        </div>

    </div>

    <div class="row" style="padding: 7px">
        <h3 class="card-title">2. Comandos de stress</h3>
        <div class="col-4">
            <div class="row" style="padding: 7px">
                <button type="button" id="btn_click_generar" class="btn btn-danger">Comando - Generar stress</button>
            </div>
            <div class="row" style="padding: 7px">
                <button type="button" id="btn_click_parar" class="btn btn-secondary">Comando - Parar stress</button>
            </div>
            <div class="row" style="padding: 7px">
                <button type="button" id="btn_click_history_commands" class="btn btn-info">Historial comandos</button>
            </div>

            <div class="row" style="padding: 7px">
                <button type="button" id="btn_click_history_clear_commands" class="btn btn-info">Historial Clear</button>
            </div>
        </div>
        <div class="col-8">

            <div style="background-color: black; color:#fff; border-radius: 15px; overflow-y: scroll; height:200px;">
                <div id="comandos_history"></div>
            </div>
        </div>
    </div>

    <div class="row" style="padding: 7px">
        <h3 class="card-title">3. Informacion de Server (CPU/MEM)</h3>
        <div class="col-4">
            <div class="row" style="padding: 7px">
                <button type="button" id="btn_info_server" class="btn btn-success">Comando - Informacion server</button>
            </div>

        </div>
        <div class="col-8">

            <div style="background-color: #821bc2; color:#fff; border-radius: 15px; overflow-y: scroll; height:150px;">
                <div id="cpu"></div>
            </div>
        </div>
    </div>

    <div class="row" style="padding: 7px">
        <h3 class="card-title">5. Extra comandos</h3>
        <div class="col-4">
            <div class="row" style="padding: 7px">
                <textarea name="cmd" id="cmd" cols="30" rows="10" style="background-color: rgba(26,23,23,0.87); color:#fff; border-radius: 15px; overflow-y: scroll; height:90px;">pwd</textarea>
                <button type="button" id="btn_cmd" class="btn btn-success">Comando - Enviar comando</button>
            </div>

        </div>
        <div class="col-8">

            <div style="background-color: rgba(26,23,23,0.87); color:#fff; border-radius: 15px; overflow-y: scroll; height:150px;">
                <div id="resul_cmd"></div>
            </div>
        </div>
    </div>


    <!--   start  ----- TOASK-------->
    <!--   start  ----- TOASK-------->
    <div class="toast-container position-fixed bottom-0 end-0 p-3" id="content_toask">

    </div>
    <!--   end  ----- TOASK-------->
    <!--   end  ----- TOASK-------->
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/axios/0.4.1/axios.min.js"></script>
<!--    <script src="axios.min.js"></script>-->

<script src="https://cdnjs.cloudflare.com/ajax/libs/dayjs/1.11.6/dayjs.min.js"
        integrity="sha512-hcV6DX35BKgiTiWYrJgPbu3FxS6CsCjKgmrsPRpUPkXWbvPiKxvSVSdhWX0yXcPctOI2FJ4WP6N1zH+17B/sAA=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dayjs/1.11.6/plugin/relativeTime.min.js"
        integrity="sha512-MVzDPmm7QZ8PhEiqJXKz/zw2HJuv61waxb8XXuZMMs9b+an3LoqOqhOEt5Nq3LY1e4Ipbbd/e+AWgERdHlVgaA=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dayjs/1.11.6/locale/es.min.js"
        integrity="sha512-zXA0Z+C+U5x6VWKPRCOQUC+5uPvpCEUM5Cs40sJXPO6Jr9Bd+j+h94eMMDcZOu5bSITZJLD83kW37oZbxGY6PA=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4"
        crossorigin="anonymous"></script>

<script>
    // agregamos el plugin a  dayjs
    dayjs.extend(dayjs_plugin_relativeTime)
    // para ponerlo en español
    dayjs.locale('es')

    const loader_web = document.getElementById('loader_web');
    const cpu = document.getElementById('cpu');
    const comandos_history = document.getElementById('comandos_history');
    // -botones
    const btn_info_server = document.getElementById('btn_info_server');
    const btn_click_generar = document.getElementById("btn_click_generar")
    const btn_click_parar = document.getElementById("btn_click_parar")
    const btn_click_history_commands = document.getElementById("btn_click_history_commands")
    const btn_click_history_clear_commands = document.getElementById("btn_click_history_clear_commands")

    // conmando shell
    const btn_cmd = document.getElementById("btn_cmd")
    const cmd = document.getElementById("cmd")
    const resul_cmd = document.getElementById("resul_cmd")




    // para los  cargadores
    const img_loading = '<img src="https://cesar23.github.io/cdn_webs/iconos_gif/spinner_cube_64px.gif" id="cargador" >'

    // para el toask de bootsrap
    const toask_container = document.getElementById('content_toask');
    const toask_template=`  <div class="toast-header">
                <img src="https://cesar23.github.io/cdn_webs/iconos_png/terminal_x24.png" class="rounded me-2"
                     alt="...">
                <strong class="me-auto">Comando</strong>
                <small>11 mins ago</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body">
                Hello, world! This is a toast message.
            </div>`

    const url_server = window.location.origin+'/index.php' ;
    /*
    ------------------------------------------------
    Para  obtener informacion del servidor
    ------------------------------------------------
     */
    const request_Info_server = async () => {
        try {
            cpu.innerHTML = img_loading
            const url =url_server + "?get_data=info_server";
            const resp = await axios.get(url);
            console.log(resp.data);
            cpu.innerHTML = `${resp.data.info_cpu} <br> ${resp.data.info_memoria} <br> ${resp.data.info_memoria_porcentaje} <br>`

        } catch (err) {
            console.error(err);
        } finally {

        }
    };

    /*
    ------------------------------------------------
    Para  obtener informacion del servidor
    ------------------------------------------------
     */
    const request_generar_stress = async () => {
        try {
            comandos_history.innerHTML = img_loading
            const url = url_server+ "?get_data=start_stress";
            const resp = await axios.get(url);
            console.log(resp.data);
            if (resp.data.statusCode === 200) {
                let output = '';
                for (let value of resp.data.msg) {
                    let arrayDeCadenas = value.split("[separador]");
                    let fecha = '<span style="color: #fff">' + arrayDeCadenas[0] + '</span>';
                    let comando = '<span style="color: #8a8a8a">' + arrayDeCadenas[1] + '</span>';
                    output += `${fecha}  >  ${comando} <br>`
                }
                comandos_history.innerHTML = output


            } else {
                console.error(resp.data.msg);
            }

        } catch (err) {
            console.error(err);
        } finally {

        }
    };

    const request_stop_stress = async () => {
        try {
            comandos_history.innerHTML = img_loading
            const url = url_server + "?get_data=stop_stress";
            const resp = await axios.get(url);
            console.log(resp.data);

            if (resp.data.statusCode === 200) {
                let output = '';
                resp.data.msg.sort(function (a, b) {
                    return a - b
                });
                for (let value of resp.data.msg) {
                    let arrayDeCadenas = value.split("[separador]");
                    let fecha = '<span style="color: #fff">' + arrayDeCadenas[0] + '</span>';
                    let comando = '<span style="color: #8a8a8a">' + arrayDeCadenas[1] + '</span>';
                    output += `${fecha}  >  ${comando} <br>`
                }
                comandos_history.innerHTML = output
            } else {
                console.error(resp.data.msg);
                //cpu.innerHTML=resp.data.msg
            }

        } catch (err) {
            console.error(err);
        } finally {

        }
    };
    const request_history_comands = async () => {
        try {
            comandos_history.innerHTML = img_loading
            const url = url_server + "?get_data=get_history_command";
            const resp = await axios.get(url);
            console.log(resp.data);


            let output = '';
            for (let value of resp.data.msg) {
                let arrayDeCadenas = value.split("[separador]");
                let fecha = '<span style="color: #fff">' + arrayDeCadenas[0] + '</span>';
                let comando = '<span style="color: #8a8a8a">' + arrayDeCadenas[1] + '</span>';
                output += `${fecha}  >  ${comando} <br>`
            }
            comandos_history.innerHTML = output


        } catch (err) {
            console.error(err);
        } finally {

        }
    };


    const request_history_clear_comands = async () => {
        try {
            comandos_history.innerHTML = img_loading
            const url = url_server+ "?get_data=get_history_clear_command";
            const resp = await axios.get(url);
            console.log(resp.data);


            let output = '';
            for (let value of resp.data.msg) {
                let arrayDeCadenas = value.split("[separador]");
                let fecha = '<span style="color: #fff">' + arrayDeCadenas[0] + '</span>';
                let comando = '<span style="color: #8a8a8a">' + arrayDeCadenas[1] + '</span>';
                output += `${fecha}  >  ${comando} <br>`
            }
            comandos_history.innerHTML = output


        } catch (err) {
            console.error(err);
        } finally {

        }
    };

    const request_comand_shell = async (cmd) => {
        try {
            resul_cmd.innerHTML = img_loading
            const url = url_server;
            const resp = await axios.post(url,{
                cmd:cmd
            });
            console.log(resp.data);


            resul_cmd.innerHTML = `${resp.data.msg}   ${resp.data.res} `


        } catch (err) {
            console.error(err);
        } finally {

        }
    };

    // const myInterval =  setInterval(sendGetRequest, 3000);
    //
    //
    // function myStopFunction() {
    //     clearInterval(myInterval);
    // }


    // btn_info_server.onclick = function () {
    //     cargador_gif.style.display = ''
    //     request_Info_server();
    // }
    // btn_click_generar.onclick = function () {
    //     cargador_gif.style.display = ''
    //     request_generar_stress();
    // }
    //
    // btn_click_parar.onclick = function () {
    //     cargador_gif.style.display = ''
    //     request_stop_stress();
    // }
    // btn_click_history_commands.onclick = function () {
    //     cargador_gif.style.display = ''
    //     request_history_comands();
    // }


    if (btn_info_server) {
        btn_info_server.addEventListener('click', async () => {
            const new_toask = document.createElement('div');
            new_toask.setAttribute("class", "toast");
            new_toask.setAttribute("role", "alert");
            new_toask.setAttribute("aria-live", "assertive");
            new_toask.setAttribute("aria-atomic", "true");

            new_toask.innerHTML=toask_template
            toask_container.appendChild(new_toask)




            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_Info_server(); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br>se obtubo Informacion de servidor`
            toast.show()

        })
    }

    if (btn_click_generar) {
        btn_click_generar.addEventListener('click', async () => {
            const new_toask = document.createElement('div');
            new_toask.setAttribute("class", "toast");
            new_toask.setAttribute("role", "alert");
            new_toask.setAttribute("aria-live", "assertive");
            new_toask.setAttribute("aria-atomic", "true");

            new_toask.innerHTML=toask_template
            toask_container.appendChild(new_toask)

            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_generar_stress(); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br>Se genero stress en el servidor `
            toast.show()

        })
    }

    if (btn_click_parar) {
        btn_click_parar.addEventListener('click', async () => {
            const new_toask = document.createElement('div');
            new_toask.setAttribute("class", "toast");
            new_toask.setAttribute("role", "alert");
            new_toask.setAttribute("aria-live", "assertive");
            new_toask.setAttribute("aria-atomic", "true");

            new_toask.innerHTML=toask_template
            toask_container.appendChild(new_toask)

            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_stop_stress(); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br>Se detuvo el stress `
            toast.show()


        })
    }

    if (btn_click_history_commands) {
        btn_click_history_commands.addEventListener('click', async () => {
            const new_toask = document.createElement('div');
            new_toask.setAttribute("class", "toast");
            new_toask.setAttribute("role", "alert");
            new_toask.setAttribute("aria-live", "assertive");
            new_toask.setAttribute("aria-atomic", "true");

            new_toask.innerHTML=toask_template
            toask_container.appendChild(new_toask)

            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_history_comands(); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br>se obtubo historial de comandos`
            toast.show()

        })
    }

   if (btn_click_history_clear_commands) {
       btn_click_history_clear_commands.addEventListener('click', async () => {
           const new_toask = document.createElement('div');
           new_toask.setAttribute("class", "toast");
           new_toask.setAttribute("role", "alert");
           new_toask.setAttribute("aria-live", "assertive");
           new_toask.setAttribute("aria-atomic", "true");

           new_toask.innerHTML=toask_template
           toask_container.appendChild(new_toask)

            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_history_clear_comands(); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br>se Limpio historial de comandos`
            toast.show()

        })
    }

    if (btn_cmd) {
        btn_cmd.addEventListener('click', async () => {
            const new_toask = document.createElement('div');
            new_toask.setAttribute("class", "toast");
            new_toask.setAttribute("role", "alert");
            new_toask.setAttribute("aria-live", "assertive");
            new_toask.setAttribute("aria-atomic", "true");

            new_toask.innerHTML=toask_template
            toask_container.appendChild(new_toask)


            const comando=cmd.value;

            let t_ahora = dayjs()
            let t_hoy = dayjs().format('YYYY-MM-DD HH:mm:ss')

            await request_comand_shell(comando); // aqui se ejecuta
            // obtenemos el tiempo transcurrido
            let t_transcurrido = dayjs().to(dayjs(t_ahora))
            const toast = new bootstrap.Toast(new_toask)
            new_toask.querySelector('small').innerHTML = `ejecutado (${t_transcurrido})`;
            new_toask.querySelector('.toast-body').innerHTML = `${t_hoy} <br> Comando`
            toast.show()

        })
    }

    /*
    ------------------------------------------------
    Para el Loading de la pagina
    ------------------------------------------------
    */

    document.addEventListener("DOMContentLoaded", function(event) {
        setTimeout(function (){
            loader_web.style.display='none'
            console.log(`cargado`)
        },2000)

    });
</script>
</body>
</html>
