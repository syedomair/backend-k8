package main

import (
	"github.com/syedomair/backend-k8/lib/container"
	"github.com/syedomair/backend-k8/lib/router"
	"github.com/syedomair/backend-k8/service/user_service/user"
)

func EndPointConf(c container.Container) []router.EndPoint {

	userController := user.Controller{
		Logger:                     c.Logger(),
		Repo:                       user.NewDBRepository(c.Db(), c.Logger()),
		PointServiceConnectionPool: c.PointServicePool(),
	}

	return []router.EndPoint{
		{
			Name:        "GetAllUser",
			Method:      router.Get,
			Pattern:     "/users",
			HandlerFunc: userController.GetAllUsers,
		},
	}
}

func EndPointConf2(c container.Container) []router.EndPoint {

	userController := user.Controller{
		Logger:                     c.Logger(),
		Repo:                       user.NewDBRepository(c.Db(), c.Logger()),
		PointServiceConnectionPool: c.PointServicePool(),
	}

	return []router.EndPoint{
		{
			Name:        "GetAllUser2",
			Method:      router.Get,
			Pattern:     "/users",
			HandlerFunc: userController.GetAllUsers2,
		},
	}
}
