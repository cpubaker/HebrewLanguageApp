from dataclasses import dataclass

from application.app_content_loader import AppContent, AppContentLoader
from application.progress_service import ProgressService
from app_paths import AppPaths
from infrastructure.content_repository import ContentRepository
from infrastructure.progress_repository import ProgressRepository


@dataclass(frozen=True)
class AppRuntime:
    paths: AppPaths
    app_content: AppContent
    progress_service: ProgressService


def build_app_runtime(paths):
    content_repository = ContentRepository(paths)
    progress_repository = ProgressRepository(paths)
    app_content = AppContentLoader(content_repository).load()
    progress_service = ProgressService(progress_repository)
    return AppRuntime(
        paths=paths,
        app_content=app_content,
        progress_service=progress_service,
    )


def build_app_runtime_from_src_file(src_file):
    paths = AppPaths.from_src_file(src_file)
    return build_app_runtime(paths)
