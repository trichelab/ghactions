# workflows ====
# these examples are based on https://help.github.com/en/articles/workflow-syntax-for-github-actions, but do look slightly different
context("workflows")

test_that("can be written out", {
  # 'on' needs to be escaped in all of the below test cases for some reason; doesn't hurt ghactions
  expect_known_output(
    object = write_workflow(workflow(name = "foo")),
    file = "workflows/named.yml"
  )
  expect_known_output(
    object = write_workflow(workflow()),
    file = "workflows/unnamed.yaml"
  )
  expect_known_output(
    # sequences must be separate lines; doesn't hurt ghactions
    object = write_workflow(workflow(on = c("push", "pull_request"))),
    file = "workflows/on_multiple.yml"
  )
  expect_known_output(
    object = write_workflow(
      workflow(
        on = on(
          event = "push",
          branches = c("master", "releases/*"),
          tags = c("v1", "v1.0")
        )
      )
    ),
    file = "workflows/on_push_filter.yml"
  )
  expect_known_output(
    object = write_workflow(
      workflow(
        on = on(
          event = "push",
          paths = c("*", "!*.js")
        )
      )
    ),
    file = "workflows/on_push_path.yml"
  )
  expect_known_output(
    object = write_workflow(
      workflow(
        on = on(
          event = "schedule",
          cron = "*/15 * * * *"
        )
      )
    ),
    file = "workflows/on_schedule.yml"
  )
})


# jobs ====
context("jobs")

test_that("can be written out", {
  expect_known_output(
    object = write_workflow(
      job(
        id = "some_job",
        name = "bar",
        needs = c("zap", "zong")
      )
    ),
    file = "workflows/job.yml"
  )
})

test_that("support matrix strategies", {
  expect_known_output(
    object = write_workflow(
      strategy(
        matrix = list(
          node = c(6L, 8L, 10L)
        ),
        `fail-fast` = TRUE,
        `max-parallel` = 3
      )
    ),
    file = "workflows/matrix_strategy.yml"
  )
})

test_that("support matrix inclusions/exclusions", {
  expect_known_output(
    object = write_workflow(
      gh_matrix(
        os = c("macOS-10.14", "windows-2016", "ubuntu-18.04"),
        node = c(4L, 6L, 8L, 10L),
        include = list(
          list(
            os = "windows-2016",
            node = 4L,
            npm = 2L
          ),
          list(
            os = "macOS-10.14",
            node = 4L,
            npm = 2L
          )
        )
      )
    ),
    file = "workflows/matrix_in_exclude.yml"
  )
})

test_that("support simple containers", {
  expect_known_output(
    object = write_workflow(
      job(
        id = "ship",
        container = "node:10.16-jessie"
      )
    ),
    file = "workflows/container_simple.yml"
  )
})

test_that("support advanced containers", {
  expect_known_output(
    object = write_workflow(
      job(
        id = "my_job",
        container = container(
          image = "node:10.16-jessie",
          env = list(NODE_ENV = "development"),
          ports = list(80L),
          volumes = list("my_docker_volume:/volume_mount"),
          options = "--cpus 1"
        )
      )
    ),
    file = "workflows/container_adv.yml"
  )
})

test_that("support additional services", {
  expect_known_output(
    object = write_workflow(
      job(
        id = "my_job",
        services = list(
          nginx = container(
            image = "nginx",
            ports = list("8080:80"),
            env = list(NGINX_PORT = (80L)),
          ),
          redis = container(
            image = "redis",
            ports = list("6379/tcp")
          )
        )
      )
    ),
    file = "workflows/services.yml"
  )
})


# steps ====
context("steps")

test_that("can be written out", {
  expect_known_output(
    object = write_workflow(
      list(
        step(
          name = "My first step",
          uses = "./.github/actions/my-action",
        ),
        step(
          name = "My backup step",
          `if` = "failure()",
          uses = "actions/heroku@master"
        )
      )
    ),
    file = "workflows/steps_first.yml"
  )
  expect_known_output(
    object = write_workflow(
      list(
        step(
          name = "My first step",
          uses = "actions/hello_world@master",
          with = list(
            first_name = "Mona",
            middle_name = "The",
            last_name = "Octocat"
          )
        )
      )
    ),
    file = "workflows/steps_with.yml"
  )
})

test_that("support multiline runs", {
  expect_known_output(
    object = write_workflow(
      list(step(run = c("foo", "bar")))
    ),
    file = "workflows/run_multiline.yml"
  )
})
