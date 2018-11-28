# Création d'une instance de l'objet Simulator
set ns [new Simulator]

# Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf

# Définir la procédure de terminaison de la simulation
proc finish {} {
	global ns nf
	$ns flush-trace
	#fermer le fichier trace
		close $nf
	#Exécuter le nam avec en entrée le fichier trace
		exec nam out.nam &
		exit 0

}
	
# Insérer votre propre code pour la création de la topologie
set n(0) [$ns node]
set n(1) [$ns node]
set n(2) [$ns node]
set n(3) [$ns node]

# Création des liens entre les noeuds
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 1.7Mb 20ms DropTail

#Positionnement des noeuds
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right

#Définit les couleurs des différents flux 
$ns color 1 Blue
$ns color 2 Red

# Création de l'agent TCP
set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp

# On affecte la classe de l'agent TCP à 1
$tcp set class_ 1

# Création de la source FTP
set ftp [new Application/FTP]

# Connection de la source FTP à l'agent tcp
$ftp attach-agent $tcp

# Création de l'agent TCPSink pour la réception des paquets dans n(3)
set tcpsink [new Agent/TCPSink]
$ns attach-agent $n(3) $tcpsink

#Connection des agents TCPSink et TCP
$ns connect $tcp $tcpsink

# Création de l'agent UDP
set udp [new Agent/UDP]
$ns attach-agent $n(1) $udp

# On affecte la classe de l'agent TCP à 1
$udp set class_ 2

# Création de la source de traffic CBR
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000
$cbr set rate_ 1Mb

# Connection de la source cbr à l'agent udp
$cbr attach-agent $udp

# Création de l'agent Null pour la réception des paquets dans n(3)
set null [new Agent/Null]
$ns attach-agent $n(3) $null

#Connection des agents Null et UDP
$ns connect $udp $null

#Déclenchement du traffic cbr à .1 et fin du traffic à 4.5
$ns at .1 "$cbr start"
$ns at 4.5 "$cbr stop"

#Déclenchement du traffic ftp à 1 et fin du traffic à 4
$ns at 1 "$ftp start"
$ns at 4 "$ftp stop"

# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5.0 "finish"

# Exécuter la simulation
$ns run
