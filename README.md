# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
 
---


## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---



## Этапы выполнения:

### Создание облачной инфраструктуры

Готовим облачную инфраструктуру при помощи Terraform:
   
  1. Создаем сервисный аккаунт и присваиваем прав для доступа к bucket.
  
<img width="892" height="138" alt="изображение" src="https://github.com/user-attachments/assets/ec97bba8-f81c-4269-8486-e5d7efedd68e" />
  
  2. Создаем [bucket](bucket/bucket.tf)

  3. Мигрируем Terrafrom.tfstate в созданный бакет. Для этого получаем ключи при помощи [output](bucket/outputs.tf). Так как ``secret_key`` имеет статус sensitive, то извлекаем командой:
     ```
     terraform output -raw terraform_backend_secret_key
     ```
Инициализируем backend конфигурацией:
     ```
     terraform init --backend-config="access_key=******" --backend-config="secret_key=******"
     ```
     
  4. Создаем [VPC](kubernetes/main.tf) с подсетями в разных зонах доступности.
 
 <img width="892" height="138" alt="изображение" src="https://github.com/user-attachments/assets/dcfb3b99-fb69-466f-ae32-e99ea99bdf19" />
  
  5. Проверяем работоспособность кода командами `terraform destroy` и `terraform apply` без дополнительных ручных действий.

<img width="786" height="208" alt="изображение" src="https://github.com/user-attachments/assets/d5c13458-eafe-4464-8f4f-787b9cac06f7" />


---
---



### Создание Kubernetes кластера

Разворачиваем самостоятельно Kubernetes кластер с помощью пакета kubespray. Для этого:
1. При помощи Terraform настраиваем [виртуальные машины](kubernetes/hosts-vm.tf) в разных зонах доступности ru-central1-a, ru-central1-b, ru-central1-d.

<img width="744" height="146" alt="изображение" src="https://github.com/user-attachments/assets/b4898184-ed28-48cf-9ab8-4a755af92148" />
   
2. Подготовим [inventory](kubernetes/infrastructure/inventory.tftpl) файл со списком хостов для insible конфигурации. В качестве мастера используем host1. Выполняем на нем установку kubespray с помощью [кода](kubernetes/cluster-k8s.tf) terraform.

<img width="1190" height="91" alt="изображение" src="https://github.com/user-attachments/assets/2d725857-7810-493f-9958-025fed4364e5" />

<img width="1190" height="331" alt="изображение" src="https://github.com/user-attachments/assets/1ff6bcb4-320b-4298-956d-f19fb3b03b41" />

Получаем работоспособный кластер k8s из трех нод (количество нод может быть любым).


---
---



### Создание тестового приложения

Для тестового приложения:
 
 1. Создаем отдельный [git репозиторий](https://github.com/oefrager/devops-diplom-app) с простым nginx конфигом, который будет отдавать статические данные. Подготовим Dockerfile для создания образа приложения.
 2. Заливаем образ с собранным docker image в регистри на [DockerHub](https://hub.docker.com/repository/docker/oefrager/nginx-app/general),

<img width="971" height="487" alt="изображение" src="https://github.com/user-attachments/assets/07543f95-3308-49a5-9d26-ee15b6fcd2f7" />

---
---



### Подготовка cистемы мониторинга и деплой приложения
Настройка мониторинга kubernetes кластера:
 
 1. Устанавливаем на кластере систему мониторинга, для этого описываем операции в [коде](kubernetes/prometheus.tf). Для этого воспользуемся пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) с полным набором инструментов, позволяющих реализовать мониторинг кластера kubernetes.
    Доступ извне к развернутым в кластере приложениям мониторинга организуем через [load-balanser](kubernetes/load-balancer.tf).
 
 Внутри:
 <img width="764" height="101" alt="изображение" src="https://github.com/user-attachments/assets/c4e2ee07-7831-45fd-985b-b4a5d1eb45c4" />

 Снаружи:
 <img width="940" height="346" alt="изображение" src="https://github.com/user-attachments/assets/b19f7ea1-50b1-47b3-9123-a76638e20784" />

 Доступ к web-интерфейсу grafana: ```admin / Pa$$w0rd```.

 <img width="1881" height="943" alt="изображение" src="https://github.com/user-attachments/assets/abfa96e6-51ed-4597-bea6-6f29b44ee087" />

  2. Задеплоим тестовое приложение [код](kubernetes/infrastructure/deploy.yaml) и получим доступ по http:
 
 <img width="1031" height="935" alt="изображение" src="https://github.com/user-attachments/assets/4c9bd382-bf85-4941-a322-c02f83e7b9eb" />


---
---


### Установка и настройка CI/CD
   
   1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
      
Настраиваем ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода. В качестве ci/cd использовал Github Actions. Для этого генерируем в Dockerhub секретный токен и прописываем его в Actions.

  <img width="967" height="97" alt="изображение" src="https://github.com/user-attachments/assets/31363e74-f8bf-4c66-b6a8-1c3b3b69f785" />

Cоздаем [YAML-файл](https://github.com/oefrager/devops-diplom-app/blob/main/.github/workflows/build.yml), который при каждом пуше в ветку main автоматически собрает проект и выкладывает на сервер.

  <img width="970" height="585" alt="изображение" src="https://github.com/user-attachments/assets/99275240-fda6-4879-a000-78b8023ff6e5" />
-

  2. Автоматический деплой нового docker образа.


---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

