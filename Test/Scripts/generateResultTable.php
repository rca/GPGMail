<?php
/**
 * Generate test case overview for the GPGMail wiki.
 *
 * @author  Alex
 * @version 2011-08-13
 */

/* -------------------------------------------------------------------------- */
define("STATUS_TBT","TBT");
define("COLOR_TBT","yellow");
define("STATUS_INV","INV");
define("COLOR_INV","gray");
define("STATUS_OK","OK");
define("COLOR_OK","green");
define("STATUS_NYI","NYI");
define("COLOR_NYI","red");
define("COLOR_ISSUE","orange");
define("SEND",0);
define("RECV",1);
define("COMMENT",2);
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
$openpgp = array ("ME","MS","MB","IE","IS","IB");
$smime = array ("NN","EE","SS","BB");
$message = array ("VT","MT"); // "VH", "MH"
$attachment = array ("NA","VA","MA");
$receiver = array ("S","M","B");
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
$result["IB"]["NN"]["VT"]["NA"]["S"][RECV] = STATUS_OK;
$result["IB"]["NN"]["VT"]["VA"]["S"][RECV] = "#239";
$result["IE"]["NN"]["VT"]["NA"]["S"][RECV] = STATUS_OK;
$result["IE"]["NN"]["VT"]["VA"]["S"][RECV] = "#239";
$result["IS"]["NN"]["MT"]["NA"]["S"][RECV] = "#240";
$result["IS"]["NN"]["VT"]["NA"]["S"][RECV] = "#237";
$result["IS"]["NN"]["VT"]["VA"]["S"][RECV] = "#221";
$result["IS"]["SS"]["VT"]["NA"]["S"][RECV] = "#244";
$result["MB"]["NN"]["MT"]["NA"]["S"][RECV] = "#241";
$result["MB"]["NN"]["VT"]["NA"]["S"][RECV] = STATUS_OK;
$result["MB"]["NN"]["VT"]["NA"]["S"][SEND] = STATUS_OK;
$result["MB"]["NN"]["VT"]["VA"]["S"][RECV] = STATUS_OK;
$result["MB"]["NN"]["VT"]["VA"]["S"][SEND] = STATUS_OK;
$result["ME"]["NN"]["VT"]["NA"]["S"][RECV] = STATUS_OK;
$result["ME"]["NN"]["VT"]["NA"]["S"][SEND] = STATUS_OK;
$result["ME"]["NN"]["VT"]["VA"]["S"][RECV] = STATUS_OK;
$result["ME"]["NN"]["VT"]["VA"]["S"][SEND] = STATUS_OK;
$result["MS"]["NN"]["MT"]["NA"]["S"][RECV] = "#240";
$result["MS"]["NN"]["VT"]["NA"]["S"][RECV] = STATUS_OK;
$result["MS"]["NN"]["VT"]["NA"]["S"][SEND] = STATUS_OK;
$result["MS"]["NN"]["VT"]["VA"]["S"][RECV] = STATUS_OK;
$result["MS"]["NN"]["VT"]["VA"]["S"][SEND] = STATUS_OK;
/* -------------------------------------------------------------------------- */

function printRow($a, $b, $c, $d, $e, $i, $result) {
    /* config --------------------------------------------------------------- */
    $template = "|%04d|%s/%s/%s/%s/%s|<font color='%s'>%s</font>|<font color='%s'>%s</font>|%s|\n";
    /* ---------------------------------------------------------------------- */

    /* results -------------------------------------------------------------- */
    $send_status = $result[$a][$b][$c][$d][$e][SEND] ?
                   $result[$a][$b][$c][$d][$e][SEND] :
                   STATUS_TBT;
    $recv_status = $result[$a][$b][$c][$d][$e][RECV] ?
                   $result[$a][$b][$c][$d][$e][RECV] :
                   STATUS_TBT;
    $comment = $result[$a][$b][$c][$d][$e][COMMENT] ?
                   $result[$a][$b][$c][$d][$e][COMMENT] :
                   "";
    /* ---------------------------------------------------------------------- */

    /* generic rules -------------------------------------------------------- */
    if ("NN" == $b && "VT" == $c && ("NA" == $d || "VA" == $d)) {
        $comment = "Important and simple use case.";
    }
    if ("M" == substr($a, 0, 1) && "NN" != $b) {
        $send_status = STATUS_INV;
        $recv_status = STATUS_INV;
        $comment = "Can't use MIME twice";
    }
    if ("NN" == $a) {
        $send_status = STATUS_INV;
        $recv_status = STATUS_INV;
        $comment .= " (No testing needed)";
    }
    if ("I" == substr($a, 0, 1)) {
        $send_status = STATUS_INV;
        $comment .= " (Sending PGP/Inline not supported)";
    }
    /* ---------------------------------------------------------------------- */

    /* set the color -------------------------------------------------------- */
    if (STATUS_TBT == $send_status) {$send_color=COLOR_TBT;}
    if (STATUS_TBT == $recv_status) {$recv_color=COLOR_TBT;}
    if (STATUS_INV == $send_status) {$send_color=COLOR_INV;}
    if (STATUS_INV == $recv_status) {$recv_color=COLOR_INV;}
    if (STATUS_OK == $send_status) {$send_color=COLOR_OK;}
    if (STATUS_OK == $recv_status) {$recv_color=COLOR_OK;}
    if (STATUS_NYI == $send_status) {$send_color=COLOR_NYI;}
    if (STATUS_NYI == $recv_status) {$recv_color=COLOR_NYI;}
    if ("#" == substr($send_status, 0, 1)) {
        $nr = substr($send_status, 1);
        $send_status = "<a href='http://gpgtools.lighthouseapp.com/projects/65764/tickets/$nr'>#$nr</a>";
        $send_color=COLOR_ISSUE;
    }
    if ("#" == substr($recv_status, 0, 1)) {
        $nr = substr($recv_status, 1);
        $recv_status = "<a href='http://gpgtools.lighthouseapp.com/projects/65764/tickets/$nr'>#$nr</a>";
        $recv_color=COLOR_ISSUE;
    }
    /* ---------------------------------------------------------------------- */


    /* ---------------------------------------------------------------------- */
    if (! (STATUS_INV == $send_status && STATUS_INV == $recv_status)) {
        $i++;
        printf ($template, $i, $a, $b, $c, $d, $e,
                $send_color, $send_status, $recv_color, $recv_status, $comment);
    }
    /* ---------------------------------------------------------------------- */
}

/* main --------------------------------------------------------------------- */
$i = 0;
foreach ($openpgp as $a) {
    foreach ($smime as $b) {
        foreach ($message as $c) {
            foreach ($attachment as $d) {
                foreach ($receiver as $e) {
                    printRow($a, $b, $c, $d, $e, &$i, &$result);
                }
            }
        }
    }
}
/* -------------------------------------------------------------------------- */

?>
