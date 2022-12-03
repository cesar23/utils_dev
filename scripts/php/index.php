<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bootstrap demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
</head>
<body>
<?php

$stressOption=$_GET['stress'];
$command="";
if(strlen($stressOption)>0){
    if($stressOption=="start"){
        $command='stress --cpu 4 --io 1 --vm 1 --vmbytes 128M --timeout 600s > /dev/null 2 >/dev/null &';
        exec($command);

    }else{
        $command='kill -9 (pidof stress)';
        exec($command);
    }
}
?>
<div class="container text-center">
    <div class="row">
        <div class="col">

        </div>
        <div class="col">
            <img src="https://pbs.twimg.com/profile_images/1377340526890872832/Qvi0U8pF_400x400.jpg" alt="">
        </div>
        <div class="col">

        </div>
    </div>
    <div class="row">
        <div class="col">
            <button type="button" onclick="?stress=start" class="btn btn-danger">Generar stress</button>
        </div>
        <div class="col">
            <button type="button" onclick="?stress=no" class="btn btn-secondary">Parar stress</button>
        </div>
        <div class="col">
            <div class="card" style="width: 18rem;">
                <div class="card-body">
                    <h5 class="card-title">Generado</h5>
                    <p><?php echo $command; ?></p>

                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
</body>
</html>
