context("GraphLearn")

test_that("basic graphlearn tests", {

  task = mlr_tasks$get("iris")

  lrn = mlr_learners$get("classif.rpart")
  gr = PipeOpLearner$new(lrn)

  glrn = GraphLearner$new(gr)
  expect_learner_fits(glrn, task)

  glrn = GraphLearner$new(gr)
  glrn$train(task)
  expect_prediction_classif({graphpred = glrn$predict(task)})
  expect_equal(graphpred,
    lrn$train(task)$predict(task))

  set.seed(1)
  resgraphlrn = resample(task, lrn, mlr_resamplings$get("cv"))
  set.seed(1)
  resjustlrn = resample(task, lrn, mlr_resamplings$get("cv"))
  expect_equal(resgraphlrn$data$prediction, resjustlrn$data$prediction)

  gr2 = PipeOpScale$new() %>>% PipeOpLearner$new(lrn)
  glrn2 = GraphLearner$new(gr2)
  expect_learner_fits(glrn, task)
  glrn2$train(task)
  expect_prediction_classif({graphpred2 = glrn2$predict(task)})

  scidf = cbind(scale(iris[1:4]), iris[5])
  scalediris = TaskClassif$new("scalediris", as_data_backend(scidf), "Species")

  dblrn = mlr_learners$get("classif.debug")
  dblrn$param_vals$save_tasks = TRUE

  dbgr = PipeOpScale$new() %>>% PipeOpLearner$new(dblrn)

  dbgr$train(task)

  dbgr$predict(task)

  dbmodels = dbgr$pipeops$classif.debug$state$model

  expect_equal(dbmodels[[1]]$data(), scalediris$data())
  expect_equal(dbmodels[[2]]$data(), scalediris$data())

})

test_that("graphlearner parameters behave as they should", {

  dblrn = mlr_learners$get("classif.debug")
  dblrn$param_vals$save_tasks = TRUE

  dbgr = PipeOpScale$new() %>>% PipeOpLearner$new(dblrn)

  expect_subset(c("scale.center", "scale.scale", "classif.debug.x"), names(dbgr$param_set$params))

  dbgr$param_vals$classif.debug.x = 1

  expect_equal(dbgr$param_vals$classif.debug.x, 1)
  expect_equal(dbgr$pipeops$classif.debug$param_vals$x, 1)
  expect_equal(dbgr$pipeops$classif.debug$learner$param_vals$x, 1)

  dbgr$pipeops$classif.debug$param_vals$x = 0

  expect_equal(dbgr$param_vals$classif.debug.x, 0)
  expect_equal(dbgr$pipeops$classif.debug$param_vals$x, 0)
  expect_equal(dbgr$pipeops$classif.debug$learner$param_vals$x, 0)

  dbgr$pipeops$classif.debug$learner$param_vals$x = 0.5

  expect_equal(dbgr$param_vals$classif.debug.x, 0.5)
  expect_equal(dbgr$pipeops$classif.debug$param_vals$x, 0.5)
  expect_equal(dbgr$pipeops$classif.debug$learner$param_vals$x, 0.5)

  expect_error({dbgr$param_vals$classif.debug.x = "a"})
  expect_error({dbgr$pipeops$classif.debug$param_vals$x = "a"})
  expect_error({dbgr$pipeops$classif.debug$learner$param_vals$x = "a"})

  expect_equal(dbgr$param_vals$classif.debug.x, 0.5)
  expect_equal(dbgr$pipeops$classif.debug$param_vals$x, 0.5)
  expect_equal(dbgr$pipeops$classif.debug$learner$param_vals$x, 0.5)

})