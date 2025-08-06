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
1. При помощи Terraform настраиваем [виртуальных машины](kubernetes/hosts-vm.tf) в разных зонах доступности ru-central1-a, ru-central1-b, ru-central1-d.

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
    Доступ к развернутым в кластере приложениям мониторинга организуем через NodePort и настраиваем [load-balanser](kubernetes/load-balancer.tf) для доступа к мониторингу извне.
 
   <img width="774" height="55" alt="изображение" src="https://github.com/user-attachments/assets/605c2dbe-1d5b-49f6-97d5-ba9e6c5600de" />
 
 
  2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.
  
  Способ выполнения:


 ### Деплой инфраструктуры в terraform pipeline
  
  1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.
  
  Ожидаемый результат:
  1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
  2. Http доступ на 80 порту к web интерфейсу grafana.
  3. Дашборды в grafana отображающие состояние Kubernetes кластера.
  4. Http доступ на 80 порту к тестовому приложению.
  5. Atlantis или terraform cloud или ci/cd-terraform

---
---



### Установка и настройка CI/CD

<details>
<summary> Установка Kubernetes кластера: </summary>
<br>
   
  Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.
  
  Цель:
  
  1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
  2. Автоматический деплой нового docker образа.
  
  Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.
  
  Ожидаемый результат:
  
  1. Интерфейс ci/cd сервиса доступен по http.
  2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
  3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

</details>

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

