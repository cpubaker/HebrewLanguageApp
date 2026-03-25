from dataclasses import dataclass

from application.app_content_loader import AppContent, AppContentLoader
from application.progress_service import ProgressService
from app_paths import AppPaths
from data_service import HebrewDataService


@dataclass(frozen=True)
class AppRuntime:
    paths: AppPaths
    data_service: HebrewDataService
    app_content: AppContent
    progress_service: ProgressService


def build_app_runtime(paths):
    data_service = HebrewDataService(paths)
    app_content = AppContentLoader(data_service).load()
    progress_service = ProgressService(data_service.progress)
    return AppRuntime(
        paths=paths,
        data_service=data_service,
        app_content=app_content,
        progress_service=progress_service,
    )


def build_app_runtime_from_src_file(src_file):
    paths = AppPaths.from_src_file(src_file)
    return build_app_runtime(paths)
