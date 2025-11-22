# Ansible-Intervlan
### COMANDOS PARA EJECUTAR LA TOPOLOGIA DE CONTAINERLAB
Al realizar el trabajo, primero se tuvo que tener en consideración los entornos de ejecución, las herramientas utilizadas para poder ejecutar el proyecto y configuraciones específicas . Primero, el entorno de ejecución fue Ubuntu en su versión 24.04 el cual fue instalado en una máquina mediante dual-boot y se accede mediante el GRUB. Luego, las herramientas elegidas fueron Containerlab en su última versión 0.71.0, luego Vrnetlab en la versión compatible con Containerlab, Docker en la versión 27.5.1, y Ansible en la versión 2.19.3. Finalmente, entre las configuraciones específicas tenemos la verificación de KVM, que en simples palabras, es la verificación que el host tiene la virtualización anidada.

https://containerlab.dev/manual/vrnetlab/ 



1. Para desplegar la topologia
- sudo containerlab deploy -t intervlan.yaml

2. Para destruir la topologia
- sudo containerlab destroy -t intervlan.yaml

3. Para ver la topologia en web
- sudo containerlab graph --topo intervlan.yaml

4. Para visualizar los nodos mediante la terminal
- sudo containerlab inspect -t intervlan.yaml

5. Para entrar a un contener mediante ssh 
- ssh admin@clab-intervlan-hos1



1. comando que sirve para listar si los inventarios se leen correctamente
- ansible-inventory --list 

2. para ejecutar el inventario de ansible
- ansible-playbook playbooks/show_interface.yml

3. comando para crear la imagen de alpine-ssh es indispensable para poder usar los nodos
- docker build -t alpine-ssh:latest -f Dockerfile.alpine-ssh .



1. Comando para iniciar terraform
- terraform init

2. Comando para mostrar los planes de terraform
- terraform plan 

3. Comando para lanzar las configuraciones de terraforms
- terraform apply -auto-approve

4. Comando para destruir terraform
- terraform destroy