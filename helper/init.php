<?php
    $inc = "debug/";

    // Log level
    error_reporting(E_ALL);

    require_once($inc."authorization.php");
    require_once($inc."communication/regions.php");

    $request = isset($_POST) && count($_POST) ? $_POST : (isset($_GET) && count($_GET) ? $_GET : null);

    $login = '';
    $password = '';
    $locale = '';
    $agent = '';
    $ip = '';
    $region = '';

    $LgnID = $PswdID = $UsrID = $UsrName = $authType = $authErr = $authDebug = $authDebug = '';

    $id = '';
    $output = '';

    $service = 'http://10.130.32.90/main_erp_copy_inet/ws/ws01';

    if (isset($request))
    {
        if (isset($request["_c"]))
        {
            $auth_code = $request["_c"];
            $id = "";
        }

        if (isset($request["locale"]))
            $locale = mb_substr($request["locale"], 0, 3);
        if (isset($request["agent"]))
            $agent = mb_substr($request["agent"], 0, 100);
        if (isset($request["ip"]))
            $ip = mb_substr($request["ip"], 0, 15);
        if (isset($request["region"]))
            $region = mb_substr($request["region"], 0, 9);
    }

    $is_valid = $id || $login;
    $is_ok = false;

    if ($id) session_id($id);
    session_start();

    if ($is_valid)
    {
        try
        {
            if ($login)
            {
                if ($UsrID && !$authErr)
                    $is_ok = true;
            }
            else
            {
                if ($id)
                    $is_ok = true;
            }
        }
        catch (Exception $err)
        {
            echo 'error: '.$err->getMessage();
        }

        if ($authErr)
        {
            echo 'error: auth service is not available';
        }
        else if ($is_ok)
        {
            $_SESSION['wms_vl_UserPageAccess__var'] = 0;
            $_SESSION['wms_vl_PageAccess__var'] = 0;

            $output = "";

            $is_ok = true;
        }
        else
        {
            echo 'error: unauthorized';
        }
    }
    else
    {
        echo 'error: not valid request:';var_dump($_POST);var_dump($_GET);
    }

    if (!$is_ok)
    {
        if (isset($_SESSION)) session_destroy();
    }
    else if ($output) echo trim($output);
?>